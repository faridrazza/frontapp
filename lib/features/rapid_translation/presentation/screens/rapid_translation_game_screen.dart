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
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:logger/logger.dart';

class RapidTranslationGameScreen extends StatefulWidget {
  final String targetLanguage;

  const RapidTranslationGameScreen({Key? key, required this.targetLanguage}) : super(key: key);

  @override
  _RapidTranslationGameScreenState createState() => _RapidTranslationGameScreenState();
}

class _RapidTranslationGameScreenState extends State<RapidTranslationGameScreen> {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  String _text = '';
  String _selectedTimer = '';
  String _selectedDifficulty = '';
  int _score = 0;
  String _gameSessionId = '';
  bool _isGameStarted = false;
  List<ChatMessage> _chatMessages = [];
  TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) => _logger.i('Speech recognition status: $status'),
      onError: (errorNotification) => _logger.e('Speech recognition error: $errorNotification'),
    );
    if (!available) {
      _logger.e('Speech recognition not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Colors.white24),
            Expanded(
              child: _isGameStarted ? _buildChatArea() : _buildGameSetup(),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _exitGame,
            child: Text('Exit Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC6F432),
              foregroundColor: Colors.black,
              textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFC6F432),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Score: $_score',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSetup() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Timer Selection Options',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                TimerButton(
                  label: '10 Seconds',
                  icon: Icons.alarm,
                  isSelected: _selectedTimer == '10',
                  onPressed: () => _selectTimer('10'),
                ),
                TimerButton(
                  label: '15 Seconds',
                  icon: Icons.alarm,
                  isSelected: _selectedTimer == '15',
                  onPressed: () => _selectTimer('15'),
                ),
                TimerButton(
                  label: '30 Seconds',
                  icon: Icons.alarm,
                  isSelected: _selectedTimer == '30',
                  onPressed: () => _selectTimer('30'),
                ),
                TimerButton(
                  label: 'No Timer',
                  icon: Icons.timer_off,
                  isSelected: _selectedTimer == 'No Timer',
                  onPressed: () => _selectTimer('No Timer'),
                ),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Difficulty Level Selection',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DifficultyButton(
                  label: 'Easy',
                  isSelected: _selectedDifficulty == 'easy',
                  onPressed: () => _selectDifficulty('easy'),
                ),
                DifficultyButton(
                  label: 'Medium',
                  isSelected: _selectedDifficulty == 'medium',
                  onPressed: () => _selectDifficulty('medium'),
                ),
                DifficultyButton(
                  label: 'Hard',
                  isSelected: _selectedDifficulty == 'hard',
                  onPressed: () => _selectDifficulty('hard'),
                ),
              ],
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _canStartGame() ? _startGame : null,
              child: Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC6F432),
                foregroundColor: Colors.black,
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        _logger.i('Building chat message: ${message.text}');
        return ChatBubble(
          message: message,
          onNextSentence: message.isButton ? _getNextSentence : null,
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Text Input Button
          _buildCircularButton(
            onPressed: _showTextInput,
            backgroundColor: Colors.grey[800]!,
            icon: Icons.keyboard,
            iconColor: Colors.white,
          ),
          // Microphone Button
          Transform.scale(
            scale: 1.2,
            child: _buildCircularButton(
              onPressed: _isListening ? _stopListening : _startListening,
              backgroundColor: Color(0xFFC6F432),
              icon: _isListening ? Icons.mic_off : Icons.mic,
              iconColor: Colors.black,
              iconSize: 30,
            ),
          ),
          // Timer Button
          _buildCircularButton(
            onPressed: () {
              // Implement timer functionality if needed
            },
            backgroundColor: Colors.grey[800]!,
            icon: Icons.timer,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    double iconSize = 24,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
        ),
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
    try {
      final result = await _apiService.startTranslationGame(_selectedDifficulty, _selectedTimer);
      setState(() {
        _gameSessionId = result['gameSessionId'];
        _isGameStarted = true;
      });
      _getNextSentence();
    } catch (e) {
      // Handle error
    }
  }

  void _getNextSentence() async {
    _logger.i('Getting next sentence');
    try {
      final response = await _apiService.getNextSentence(_gameSessionId);
      _logger.i('Received next sentence response: $response');

      if (response is Map<String, dynamic>) {
        final String nextSentence = response['sentence'] ?? 'No sentence provided';
        final String sourceLanguage = response['sourceLanguage'] ?? 'Unknown';
        
        _logger.i('Next sentence: $nextSentence');
        _logger.i('Source language: $sourceLanguage');

        setState(() {
          _chatMessages.add(ChatMessage(
            text: 'Translate from $sourceLanguage:\n$nextSentence',
            isSystem: true,
            isError: false,
          ));
        });
        _scrollToBottom();
        _showNewSentenceIndicator();
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

  void _submitTranslation(String translation) async {
    _logger.i('Submitting translation: $translation');
    setState(() {
      _isLoading = true;
    });

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
      setState(() {
        _chatMessages.add(ChatMessage(
          text: 'Error submitting translation. Please try again.',
          isSystem: false,
          isError: true,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
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

  void _startListening() async {
    _logger.i('Starting speech recognition');
    if (!_isListening) {
      if (await _speech.initialize()) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: _onSpeechResult,
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: true,
          localeId: widget.targetLanguage,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    }
  }

  void _stopListening() async {
    _logger.i('Stopping speech recognition');
    await _speech.stop();
    setState(() => _isListening = false);
    
    if (_text.isNotEmpty) {
      _logger.i('Submitting recognized text: $_text');
      _submitTranslation(_text);
      setState(() {
        _chatMessages.add(ChatMessage(
          text: _text,
          isSystem: false,
          isError: false,
        ));
      });
      _scrollToBottom();
      _text = ''; // Clear the text after submitting
    } else {
      _logger.w('No text recognized');
    }
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type your translation...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black,
                ),
                autofocus: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
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
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC6F432),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
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

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
      _logger.i('Recognized words: $_text');
    });
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
}