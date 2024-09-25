import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import other necessary widgets and services

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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _isKeyboardVisible.value = keyboardHeight > 0;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    // Implement OTP verification logic here
    // For now, let's just set an error message if the OTP is invalid
    setState(() {
      if (_otpController.text != '1234') { // Replace with actual OTP validation
        _errorMessage = 'Invalid OTP. Please try again.';
      } else {
        _errorMessage = '';
        // Navigate to the next screen or perform necessary action
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _WaveBackground(
        isKeyboardVisibleNotifier: _isKeyboardVisible,
        child: SafeArea(
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
                      onPressed: _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6F432),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Verify OTP',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class _WaveBackground extends StatelessWidget {
  final Widget child;
  final ValueNotifier<bool> isKeyboardVisibleNotifier;

  const _WaveBackground({
    Key? key,
    required this.child,
    required this.isKeyboardVisibleNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isKeyboardVisibleNotifier,
          builder: (context, isKeyboardVisible, _) {
            return AnimatedOpacity(
              opacity: isKeyboardVisible ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    bottom: MediaQuery.of(context).size.height * 0.4,
                    child: Image.asset(
                      'assets/images/waveleft.png',
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    bottom: MediaQuery.of(context).size.height * 0.35,
                    child: Image.asset(
                      'assets/images/waveleft.png',
                      height: MediaQuery.of(context).size.height * 0.28,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        child,
      ],
    );
  }
}