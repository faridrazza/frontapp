import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final bool isProcessing;

  const VoiceInputButton({
    Key? key,
    required this.onRecordingComplete,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  double _confidenceLevel = 0.0;

  // Animation controller for the pulse effect
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeAnimations();
  }

  void _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => _logger.i('Speech recognition status: $status'),
        onError: (errorNotification) => _logger.e('Speech recognition error: $errorNotification'),
      );
      _logger.i('Speech recognition available: $available');
    } catch (e) {
      _logger.e('Error initializing speech recognition: $e');
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  void _startListening() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (result) {
              setState(() {
                _confidenceLevel = result.confidence;
              });
              if (result.finalResult) {
                widget.onRecordingComplete(result.recognizedWords);
                _stopListening();
              }
            },
            listenFor: Duration(seconds: 30),
            pauseFor: Duration(seconds: 3),
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.confirmation,
          );
          _logger.i('Started listening');
        }
      }
    } catch (e) {
      _logger.e('Error starting speech recognition: $e');
      _showError('Could not start voice recognition');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _confidenceLevel = 0.0;
    });
    _logger.i('Stopped listening');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse effect
                if (_isListening)
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFC8F235).withOpacity(_opacityAnimation.value),
                      ),
                    ),
                  ),
                // Main button
                GestureDetector(
                  onTapDown: (_) => _startListening(),
                  onTapUp: (_) => _stopListening(),
                  onTapCancel: () => _stopListening(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : Color(0xFFC8F235),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Color(0xFFC8F235))
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: widget.isProcessing
                        ? Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.black,
                            size: 30,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        if (_isListening && _confidenceLevel > 0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }
}
