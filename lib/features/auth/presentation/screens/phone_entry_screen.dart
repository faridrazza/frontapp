import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/auth/presentation/widgets/ai_orb.dart';
import 'package:frontapp/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:frontapp/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:logger/logger.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({Key? key}) : super(key: key);

  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final ApiService _apiService = ApiService();
  String _phoneNumber = '';
  String _countryCode = '';
  bool _isValid = false;
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier<bool>(false);
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _isKeyboardVisible.value = keyboardHeight > 0;
    });
  }

  void _updatePhoneNumber(String number, bool isValid) {
    setState(() {
      _phoneNumber = number;
      _isValid = isValid;
    });
    _logger.d('Phone number updated: $number, Is valid: $isValid');
    
    // Extract country code and phone number correctly
    final RegExp regExp = RegExp(r'^\+(\d+)\s*(.*)$');
    final Match? match = regExp.firstMatch(number);
    
    if (match != null && match.groupCount == 2) {
      _countryCode = '+${match.group(1)}';
      _phoneNumber = match.group(2)!.replaceAll(RegExp(r'\D'), '');
      
      // Ensure the country code is not longer than 4 digits (including the '+')
      if (_countryCode.length > 4) {
        _phoneNumber = _countryCode.substring(4) + _phoneNumber;
        _countryCode = _countryCode.substring(0, 4);
      }
    } else {
      _countryCode = '';
      _phoneNumber = number.replaceAll(RegExp(r'\D'), '');
    }
    
    _logger.d('Extracted country code: $_countryCode');
    _logger.d('Extracted phone number: $_phoneNumber');
  }

  Future<void> _sendOtp() async {
    _logger.i('Attempting to send OTP');
    _logger.d('Phone number: $_phoneNumber');
    _logger.d('Country code: $_countryCode');
    _logger.d('Is valid: $_isValid');

    if (!_isValid) {
      _logger.w('Phone number is not valid. Aborting OTP send.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    try {
      _logger.d('Calling API service to send OTP');
      final response = await _apiService.sendOtp(_countryCode, _phoneNumber);
      _logger.i('OTP sent successfully');
      _logger.d('API response: $response');

      if (response['message'] != null) {
        _logger.d('Navigating to VerifyOtpScreen');
        _navigateToVerifyOtp();
      } else {
        _logger.w('Unexpected API response format');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    } catch (e) {
      _logger.e('Error sending OTP', error: e);
      _logger.d('Error details: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP: ${e.toString()}')),
      );
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
                          ElevatedButton(
                            onPressed: () {
                              // This button no longer submits the phone number
                              // You can add any other functionality here if needed
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isValid ? Colors.black : const Color(0xFFC6F432),
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
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC6F432),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Submit',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'By using Englishbro, you agree to our Terms & Conditions and Privacy policy',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
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