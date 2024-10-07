import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/auth/presentation/screens/complete_profile_screen.dart';
import 'package:frontapp/features/auth/presentation/screens/home_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;

  const VerifyOtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.countryCode,
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier<bool>(false);
  final ApiService _apiService = ApiService();
  String _errorMessage = '';
  int _timerSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _isKeyboardVisible.value = keyboardHeight > 0;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Actual API implementation
    try {
      final response = await _apiService.verifyOtp(
        widget.countryCode,
        widget.phoneNumber,
        _otpController.text,
      );

      if (response['isProfileComplete']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(isNewUser: false)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => CompleteProfileScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }

    // Mock implementation (commented out)
    // await Future.delayed(Duration(seconds: 2));
    // if (_otpController.text == '1234') {
    //   bool isProfileComplete = DateTime.now().millisecond % 2 == 0;

    //   if (isProfileComplete) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (_) => HomeScreen(isNewUser: false)),
    //     );
    //   } else {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (_) => CompleteProfileScreen()),
    //     );
    //   }
    // } else {
    //   setState(() {
    //     _errorMessage = 'Invalid OTP. Please try again. Hint: Use 1234';
    //   });
    // }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _apiService.resendOtp(widget.countryCode, widget.phoneNumber);
      setState(() {
        _timerSeconds = 60;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              _isKeyboardVisible.value = keyboardHeight > 0;
            }
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isKeyboardVisible,
                    builder: (context, isKeyboardVisible, child) {
                      return AnimatedOpacity(
                        opacity: isKeyboardVisible ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Verify OTP',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We have sent you a 4-digit OTP.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter OTP',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC6F432),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'Verify OTP',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (_timerSeconds > 0)
                    Text(
                      'Resend OTP in ${_timerSeconds}s',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    TextButton(
                      onPressed: _isLoading ? null : _resendOtp,
                      child: Text(
                        'Resend OTP',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC6F432),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}