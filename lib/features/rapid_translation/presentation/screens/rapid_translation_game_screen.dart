import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/rapid_translation/presentation/bloc/rapid_translation_bloc.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/chat_bubble.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/timer_button.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/difficulty_button.dart';
import 'package:frontapp/features/rapid_translation/domain/models/chat_message.dart';
import 'package:logger/logger.dart';
import 'dart:async'; // Add this import
import 'package:frontapp/features/rapid_translation/presentation/widgets/voice_input_button.dart';

class RapidTranslationGameScreen extends StatefulWidget {
  final String targetLanguage;

  const RapidTranslationGameScreen({
    Key? key,
    required this.targetLanguage,
  }) : super(key: key);

  @override
  _RapidTranslationGameScreenState createState() => _RapidTranslationGameScreenState();
}

class _RapidTranslationGameScreenState extends State<RapidTranslationGameScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();
  String _selectedTimer = '';
  String _selectedDifficulty = '';
  String _gameSessionId = '';
  bool _isGameStarted = false;
  List<ChatMessage> _chatMessages = [];
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showIndicator = false;
  Timer? _timer;
  int _remainingTime = 0;
  bool _isPaused = false;
  int _remainingTimeWhenPaused = 0;
  bool _shouldStopVoiceInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010101),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildGameArea(),
            if (_isGameStarted) _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Color(0xFF121212),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          if (_isGameStarted && _selectedTimer != 'No Timer')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFC6F432).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFC6F432).withOpacity(0.3)),
              ),
              child: Text(
                '$_remainingTime s',
                style: GoogleFonts.poppins(
                  color: Color(0xFFC6F432),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFC6F432).withOpacity(0.1),
              border: Border.all(color: Color(0xFFC6F432).withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Color(0xFFC6F432),
              ),
              onPressed: _isPaused ? _resumeGame : _pauseGame,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF121212),
          
        ),
        child: _isGameStarted
            ? _buildChatArea()
            : _buildGameSetup(),
      ),
    );
  }

  Widget _buildGameSetup() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Title with Gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Rapid Translation\nGame',
              style: GoogleFonts.poppins(
                fontSize: 32,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Select Difficulty',
            style: GoogleFonts.poppins(
              color: Color(0xFFC6F432),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDifficultyOption('Easy', Color(0xFFC6F432)),
              _buildDifficultyOption('Medium', Color(0xFF7B61FF)),
              _buildDifficultyOption('Hard', Color(0xFFFEC4DD)),
            ],
          ),
          SizedBox(height: 32),
          Text(
            'Select Timer',
            style: GoogleFonts.poppins(
              color: Color(0xFF90E0EF),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTimerOption('No Timer', Color(0xFFC09FF8)),
              _buildTimerOption('20', Color(0xFF7B61FF)),
              _buildTimerOption('40', Color(0xFFFFB341)),
              _buildTimerOption('60', Color(0xFFFEC4DD)),
            ],
          ),
          Spacer(),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFC6F432).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Start Game',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption(String difficulty, Color color) {
    final bool isSelected = _selectedDifficulty == difficulty;
    return Container(
      height: 80,
      width: (MediaQuery.of(context).size.width - 72) / 3,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _selectedDifficulty = difficulty),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getDifficultyIcon(difficulty),
                color: isSelected ? color : color.withOpacity(0.7),
                size: 24,
              ),
              SizedBox(height: 6),
              Text(
                difficulty,
                style: GoogleFonts.poppins(
                  color: isSelected ? color : color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Icons.sentiment_satisfied_alt;
      case 'Medium':
        return Icons.sentiment_neutral;
      case 'Hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTimerOption(String timer, Color color) {
    final bool isSelected = _selectedTimer == timer;
    return Container(
      height: 80,
      width: (MediaQuery.of(context).size.width - 72) / 2,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => setState(() => _selectedTimer = timer),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                color: isSelected ? color : color.withOpacity(0.7),
                size: 24,
              ),
              SizedBox(height: 6),
              Text(
                timer == 'No Timer' ? timer : '$timer sec',
                style: GoogleFonts.poppins(
                  color: isSelected ? color : color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      color: Color(0xFF121212),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        physics: BouncingScrollPhysics(),
        itemCount: _chatMessages.length,
        itemBuilder: (context, index) {
          final message = _chatMessages[index];
          
          return AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: message.isLoading ? 0.7 : 1.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: ChatBubble(
                  message: message,
                  onNextSentence: message.isButton ? _getNextSentence : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: Row(
        children: [
          VoiceInputButton(
            isProcessing: _isLoading,
            shouldStopRecording: _shouldStopVoiceInput,
            onRecordingComplete: (String text) {
              if (text.isNotEmpty && !_shouldStopVoiceInput) {
                setState(() {
                  _chatMessages.add(ChatMessage(
                    text: text,
                    isSystem: false,
                    isError: false,
                  ));
                });
                _submitTranslation(text);
                _scrollToBottom();
              }
            },
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showTextInput,
              child: Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type your translation...',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTimer(String timer) {
    setState(() {
      _selectedTimer = timer == 'no' ? 'No Timer' : timer;
    });
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
  }

  bool _canStartGame() {
    return _selectedTimer.isNotEmpty && _selectedDifficulty.isNotEmpty;
  }

  void _startGame() async {
    if (!_canStartGame() || _isLoading) return;
    try {
      setState(() {
        _isLoading = true;
      });
      final result = await _apiService.startTranslationGame(_selectedDifficulty, _selectedTimer);
      setState(() {
        _gameSessionId = result['gameSessionId'];
        _isGameStarted = true;
      });
      await _getNextSentence(); // Wait for the first sentence
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state after receiving the first sentence
      });
    }
  }

  Future<void> _getNextSentence() async {
    if (_isPaused) return;
    setState(() {
      _shouldStopVoiceInput = false; // Reset when getting new sentence
    });
    _logger.i('Getting next sentence');
    try {
      final response = await _apiService.getNextSentence(_gameSessionId);
      _logger.i('Received next sentence response: $response');

      if (response is Map<String, dynamic>) {
        final String nextSentence = response['sentence'] ?? 'No sentence provided';
        _logger.i('Next sentence: $nextSentence');

        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Translate: $nextSentence',
            isSystem: true,
            isError: false,
          ));
          _scrollToBottom();
          _showNewSentenceIndicator();
          _startTimer(); // Start the timer after receiving a new sentence
        });
      } else {
        _logger.w('Unexpected response format: $response');
        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Unexpected response format. Please try again.',
            isSystem: true,
            isError: true,
          ));
        });
      }
    } catch (e) {
      _logger.e('Error getting next sentence: $e');
      setState(() {
        _chatMessages.add(ChatMessage(
          text: 'Error getting next sentence. Please try again.',
          isSystem: true,
          isError: true,
        ));
      });
      _scrollToBottom();
    }
  }

  void _startTimer() {
    if (_selectedTimer != 'No Timer' && !_isPaused) {
      _timer?.cancel();
      setState(() {
        _remainingTime = int.parse(_selectedTimer);
        _shouldStopVoiceInput = false;
      });
      
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_remainingTime > 0) {
              _remainingTime--;
            } else {
              _timer?.cancel();
              _shouldStopVoiceInput = true; // Set to true when timer expires
              _handleTimeUp();
            }
          });
        } else {
          _timer?.cancel();
        }
      });
    }
  }

  void _handleTimeUp() async {
    if (!mounted) return;
    setState(() {
      _shouldStopVoiceInput = true;
      _isLoading = true;
    });
    try {
      final Map<String, dynamic> response = await _apiService.timeUp(_gameSessionId);
      _logger.i('Time up response: $response');

      if (mounted) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Time\'s up!',
            isSystem: true,
            isError: false,
          ));

          if (response['correctTranslation'] != null) {
            _chatMessages.add(ChatMessage(
              text: 'Correct translation: ${response['correctTranslation']}',
              isSystem: true,
              isError: false,
            ));
          }
        });
        _scrollToBottom();

        // Add a slight delay before getting the next sentence
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _shouldStopVoiceInput = false; // Reset for next sentence
            });
            _getNextSentence();
          }
        });
      }
    } catch (e) {
      _logger.e('Error handling time up: $e');
      if (mounted) {
        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Error: Unable to get the correct translation.',
            isSystem: true,
            isError: true,
          ));
          // Even if there's an error, try to get the next sentence
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) _getNextSentence();
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _submitTranslation(String translation) async {
    if (_isPaused || !mounted) return;
    _timer?.cancel();
    try {
      final int timeTaken = _calculateTimeTaken(); // Implement this method
      final response = await _apiService.submitTranslation(
        _gameSessionId,
        translation,
        timeTaken,
      );
      _logger.i('Raw response from backend: $response');

      if (response is Map<String, dynamic>) {
        _logger.i('isCorrect: ${response['isCorrect']}');
        _logger.i('correctTranslation: ${response['correctTranslation']}');

        final bool isCorrect = response['isCorrect'] ?? false;
        final String? correctTranslation = response['correctTranslation'];

        setState(() {
          _chatMessages.add(ChatMessage(
            text: isCorrect 
                ? 'Correct translation!'
                : 'Incorrect. The correct translation is: $correctTranslation',
            isSystem: true,
            isError: false,
            isCorrect: isCorrect,
          ));
          // Update score or other game state if needed
          _isLoading = false;
        });
      } else {
        _logger.w('Unexpected response format: $response');
        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Unexpected response from server.',
            isSystem: true,
            isError: true,
          ));
          _isLoading = false;
        });
      }

      _scrollToBottom();
      _logger.i('Calling _getNextSentence after submitting translation');
      _getNextSentence();
    } catch (e) {
      _logger.e('Error submitting translation: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _chatMessages.add(ChatMessage(
            text: 'Error submitting translation. Please try again.',
            isSystem: true,
            isError: true,
          ));
        });
      }
    }
  }

  void _exitGame() async {
    try {
      await _apiService.endTranslationGame(_gameSessionId);
      Navigator.of(context).pop();
    } catch (e) {
      // Handle error
    }
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    // borderRadius: BorderRadius.circular(25),
                    // border: Border.all(
                    //   color: Color(0xFFC6F432).withOpacity(0.3),
                    // ),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your translation...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                    autofocus: true,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        setState(() {
                          _chatMessages.add(ChatMessage(
                            text: _textController.text,
                            isSystem: false,
                            isError: false,
                          ));
                        });
                        _submitTranslation(_textController.text);
                        Navigator.pop(context);
                        _textController.clear();
                        _scrollToBottom();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC6F432),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Send',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showNextSentenceButton() {
    setState(() {
      _chatMessages.add(ChatMessage(
        text: 'Get the next sentence',
        isSystem: true,
        isButton: true,
      ));
    });
    _scrollToBottom();
  }

  // Implement this method to calculate the time taken for the translation
  int _calculateTimeTaken() {
    // This is a placeholder implementation. Replace with your actual logic.
    return 0; // Return the time taken in seconds or milliseconds
  }

  void _showNewSentenceIndicator() {
    setState(() {
      _showIndicator = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showIndicator = false;
      });
    });
  }

  void _pauseGame() {
    if (_isGameStarted && !_isPaused) {
      setState(() {
        _isPaused = true;
        _remainingTimeWhenPaused = _remainingTime;
      });
      _timer?.cancel();
    }
  }

  void _resumeGame() {
    if (_isGameStarted && _isPaused) {
      setState(() {
        _isPaused = false;
        _remainingTime = _remainingTimeWhenPaused;
      });
      _startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      _resumeGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
