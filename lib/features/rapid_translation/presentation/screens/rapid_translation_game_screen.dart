import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/rapid_translation/presentation/bloc/rapid_translation_bloc.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/chat_bubble.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/timer_button.dart';
import 'package:frontapp/features/rapid_translation/presentation/widgets/difficulty_button.dart';
import 'package:frontapp/features/rapid_translation/domain/models/chat_message.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RapidTranslationGameScreen extends StatefulWidget {
  const RapidTranslationGameScreen({Key? key}) : super(key: key);

  @override
  _RapidTranslationGameScreenState createState() => _RapidTranslationGameScreenState();
}

class _RapidTranslationGameScreenState extends State<RapidTranslationGameScreen> {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
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

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) => print('Speech recognition error: $errorNotification'),
    );
    if (available) {
      print('Speech recognition initialized successfully');
    } else {
      print('Speech recognition not available');
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
        return ChatBubble(message: _chatMessages[index]);
      },
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard, color: Color(0xFFA460F3)),
            onPressed: _showTextInput,
          ),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.black),
            backgroundColor: Color(0xFFC6F432),
          ),
          IconButton(
            icon: Icon(Icons.timer, color: Colors.grey),
            onPressed: () {}, // Timer functionality
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
    try {
      final result = await _apiService.getNextSentence(_gameSessionId);
      setState(() {
        _chatMessages.add(ChatMessage(
          text: result['sentence'],
          isSystem: true,
        ));
      });
      _scrollToBottom();
    } catch (e) {
      // Handle error
    }
  }

  void _submitTranslation(String translation) async {
    try {
      final result = await _apiService.submitTranslation(_gameSessionId, translation, 0); // Replace 0 with actual time taken
      setState(() {
        _chatMessages.add(ChatMessage(
          text: translation,
          isSystem: false,
          isCorrect: result['isCorrect'],
        ));
        if (!result['isCorrect']) {
          _chatMessages.add(ChatMessage(
            text: result['correctTranslation'],
            isSystem: true,
            isCorrect: true,
          ));
        }
        _score = result['score'];
      });
      _scrollToBottom();
      _showNextSentenceButton();
    } catch (e) {
      print('Error submitting translation: $e');
      // Handle error (e.g., show an error message to the user)
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
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: false,
          onSoundLevelChange: (level) => print('Sound level: $level'),
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_text.isNotEmpty) {
      _submitTranslation(_text);
      _text = '';
    }
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type your translation here',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _submitTranslation(_textController.text);
                  Navigator.pop(context);
                  _textController.clear();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
}