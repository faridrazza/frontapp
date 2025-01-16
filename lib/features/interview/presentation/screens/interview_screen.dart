import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

// Import local widgets
import '../widgets/voice_input_button.dart';
import '../widgets/interview_message_bubble.dart';
import '../widgets/role_selection_form.dart';

// Import other local files
import '../bloc/interview_bloc.dart';
import '../bloc/interview_state.dart';
import '../bloc/interview_event.dart';
import '../../domain/models/interview_message.dart';
import '../../../../core/utils/audio_utils.dart';
import 'interview_feedback_screen.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({Key? key}) : super(key: key);

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isMicAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final Logger _logger = Logger();
  bool _isAudioPlaying = false;
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  InterviewMessage? _currentMessage;
  final TextEditingController _roleController = TextEditingController();
  String _selectedExperience = 'fresher';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSpeech();
    _initializeAnimations();
    _initializeVideo();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          setState(() => _isListening = status == 'listening');
          if (_isListening) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.reset();
          }
        },
        onError: (error) => _showError('Microphone error: ${error.errorMsg}'),
      );
      setState(() => _isMicAvailable = available);
    } catch (e) {
      _showError('Failed to initialize microphone');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isMicAvailable) {
      _showError('Microphone not available');
      return;
    }

    try {
      if (await _speech.initialize(
        onStatus: (status) {
          _logger.i('Speech recognition status: $status');
          if (status == 'notListening') {
            if (_isListening) {
              _showError('No speech detected for a while');
              _stopListening();
            }
          }
          setState(() => _isListening = status == 'listening');
          if (_isListening) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.reset();
          }
        },
        onError: (error) {
          if (error.errorMsg != 'No speech input') {
            _showError('Microphone error: ${error.errorMsg}');
          }
        },
      )) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              if (result.recognizedWords.isNotEmpty) {
                context.read<InterviewBloc>().add(
                  SendResponse(result.recognizedWords),
                );
              }
            }
          },
          listenMode: stt.ListenMode.dictation,
          pauseFor: Duration(seconds: 10),
          partialResults: true,
          cancelOnError: false,
          localeId: 'en_US',
        );
      }
    } catch (e) {
      _logger.e('Error starting microphone: $e');
      _showError('Error starting microphone');
      _stopListening();
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      _logger.e('Error stopping microphone: $e');
      _showError('Error stopping microphone');
    }
  }

  Future<void> _playAudio(String audioBuffer) async {
    if (_isAudioPlaying) {
      await AudioUtils.stopAudio();
      setState(() => _isAudioPlaying = false);
      return;
    }
    
    setState(() => _isAudioPlaying = true);
    try {
      await AudioUtils.playAudio(audioBuffer);
    } finally {
      if (mounted) {
        setState(() => _isAudioPlaying = false);
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/videos/interview_avatar.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: true,
        ),
      );

      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0.0);
      await _videoController.setPlaybackSpeed(1.0);
      
      await _videoController.play();
      await _videoController.pause();
      await _videoController.seekTo(Duration.zero);
      
      setState(() => _isVideoInitialized = true);
    } catch (e) {
      _logger.e('Error initializing video: $e');
    }
  }

  Future<void> _handleMediaPlayback(InterviewMessage message) async {
    if (!_isVideoInitialized || message.audioBuffer == null) return;

    try {
      await _stopPlayback();
      
      // Ensure video is ready at the start
      await _videoController.seekTo(Duration.zero);
      await Future.delayed(const Duration(milliseconds: 50));
      
      setState(() {
        _isAudioPlaying = true;
        _currentMessage = message;
      });

      // Start video first
      await _videoController.play();
      
      // Monitor video playback
      _videoController.addListener(_monitorVideoPlayback);
      
      // Play audio with completion callback
      await AudioUtils.playAudio(
        message.audioBuffer!,
        onComplete: () {
          if (mounted) {
            _stopPlayback();
          }
        },
      );
    } catch (e) {
      _logger.e('Error during media playback: $e');
      _stopPlayback();
    }
  }

  void _monitorVideoPlayback() {
    if (!mounted) return;
    
    if (_isAudioPlaying && !_videoController.value.isPlaying) {
      _videoController.play();
    }
    
    if (_videoController.value.hasError) {
      _logger.e('Video playback error: ${_videoController.value.errorDescription}');
      _stopPlayback();
    }
  }

  Future<void> _stopPlayback() async {
    if (!mounted) return;
    
    _videoController.removeListener(_monitorVideoPlayback);
    
    setState(() => _isAudioPlaying = false);
    
    await AudioUtils.stopAudio();
    await _videoController.pause();
    await _videoController.seekTo(Duration.zero);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopPlayback();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010101),
      body: SafeArea(
        child: BlocConsumer<InterviewBloc, InterviewState>(
          listener: (context, state) {
            if (state is InterviewCompleted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InterviewFeedbackScreen(feedback: state.feedback),
                ),
              );
            } else if (state is InterviewInProgress) {
              if (state.session.messages.isNotEmpty) {
                final latestMessage = state.session.messages.last;
                if (latestMessage.isAI && latestMessage.audioBuffer != null) {
                  _handleMediaPlayback(latestMessage);
                }
                Future.delayed(Duration(milliseconds: 100), () {
                  _scrollToBottom();
                });
              }
            }
          },
          builder: (context, state) {
            if (state is InterviewInitial) {
              return _buildSetupScreen();
            }
            return Column(
              children: [
                // Video Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: Colors.black,
                  child: _isVideoInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F432)),
                          ),
                        ),
                ),
                // Chat Section
                Expanded(
                  child: _buildChatSection(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Interview\nPreparation',
                style: GoogleFonts.poppins(
                  fontSize: 45,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 50),
            
            // Role Selection
            Text(
              'Select Role',
              style: GoogleFonts.poppins(
                color: Color(0xFFC6F432),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildRoleTextField(),
            
            SizedBox(height: 40),
            
            // Experience Level
            Text(
              'Experience Level',
              style: GoogleFonts.poppins(
                color: Color(0xFF90E0EF),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildExperienceLevelSelector(),
            
            SizedBox(height: 32),
            
            // Start Button
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
                onPressed: _canStartInterview() ? _startInterview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  'Start Interview',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTextField() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFFC6F432).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFC6F432).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _roleController,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Java Developer',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              height: 1.5,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.work_outline,
                color: Color(0xFFC6F432),
                size: 20,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            isDense: true,
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      ),
    );
  }

  Widget _buildExperienceLevelSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildExperienceOption('Fresher', 'fresher', Color(0xFF7B61FF)),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildExperienceOption('Experienced', 'experienced', Color(0xFFFEC4DD)),
        ),
      ],
    );
  }

  Widget _buildExperienceOption(String label, String value, Color color) {
    final bool isSelected = _selectedExperience == value;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedExperience = value),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                value == 'fresher' ? Icons.school : Icons.work,
                color: isSelected ? color : color.withOpacity(0.7),
                size: 24,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? color : color.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canStartInterview() {
    return _roleController.text.isNotEmpty && _selectedExperience.isNotEmpty;
  }

  void _startInterview() {
    if (_canStartInterview()) {
      context.read<InterviewBloc>().add(
        StartInterview(
          role: _roleController.text,
          experienceLevel: _selectedExperience,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _stopListening();
    _scrollController.dispose();
    AudioUtils.stopAudio();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildChatSection(InterviewState state) {
    if (state is InterviewLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F432)),
        ),
      );
    }

    if (state is InterviewInProgress) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 16),
              itemCount: state.session.messages.length,
              itemBuilder: (context, index) {
                final message = state.session.messages[index];
                return InterviewMessageBubble(
                  message: message,
                  isPlaying: _isAudioPlaying && _currentMessage == message,
                  onPlayMedia: _handleMediaPlayback,
                );
              },
            ),
          ),
          if (state.isProcessing)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F432)),
              ),
            ),
          // Bottom controls with mic and end button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFC6F432).withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // End Interview Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.read<InterviewBloc>().add(EndInterview());
                    },
                    child: Text(
                      'End Interview',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Voice Input Button
                VoiceInputButton(
                  onRecordingComplete: (response) {
                    context.read<InterviewBloc>().add(SendResponse(response));
                  },
                  isProcessing: state.isProcessing,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SizedBox.shrink();
  }
}
