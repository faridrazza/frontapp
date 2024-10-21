import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontapp/features/auth/presentation/widgets/ai_orb.dart';
import 'package:frontapp/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:frontapp/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:flutter/gestures.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({Key? key}) : super(key: key);

  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();
  String _phoneNumber = '';
  String _countryCode = '';
  bool _isValid = false;
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier<bool>(false);
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _isKeyboardVisible.value = keyboardHeight > 0;
    });
  }

  void _updatePhoneNumber(String countryCode, String phoneNumber, bool isValid) {
    setState(() {
      _countryCode = countryCode;
      _phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (_phoneNumber.startsWith(_countryCode.replaceAll('+', ''))) {
        _phoneNumber = _phoneNumber.substring(_countryCode.length - 1);
      }
      _isValid = isValid;
    });
  }

  Future<void> _sendOtp() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    try {
      final response = await _apiService.sendOtp(_countryCode, _phoneNumber);
      if (response['message'] != null) {
        _navigateToVerifyOtp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  void _navigateToVerifyOtp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyOtpScreen(
          phoneNumber: _phoneNumber,
          countryCode: _countryCode,
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
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
                                child: Column(
                                  children: [
                                    Text(
                                      'Improve Your\nEnglish speaking\nskills with AI',
                                      style: GoogleFonts.inter(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const AiOrb(),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          if (!_isValid) // Only show this button if the number is not valid
                            ElevatedButton(
                              onPressed: () {
                                // This button no longer submits the phone number
                                // You can add any other functionality here if needed
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC6F432),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Enter Phone Number',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          PhoneInputField(
                            onInputChanged: _updatePhoneNumber,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isValid)
                        ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC6F432),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                        ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(
                              text: 'By using Englishbro, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchURL('https://speakjar.blogspot.com/2024/10/terms-and-conditions.html');
                                },
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchURL('https://speakjar.blogspot.com/2024/10/data-custom-classbody-data-custom.html');
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
