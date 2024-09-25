import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/auth/presentation/widgets/ai_orb.dart';
import 'package:frontapp/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:frontapp/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:frontapp/core/services/api_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({Key? key}) : super(key: key);

  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  String _phoneNumber = '';
  String _countryCode = '';
  bool _isValid = false;
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier<bool>(false);
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      _isKeyboardVisible.value = keyboardHeight > 0;
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _showScrollIndicator = _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _updatePhoneNumber(String number, bool isValid) {
    setState(() {
      _phoneNumber = number;
      _isValid = isValid;
      _countryCode = number.startsWith('+') ? number.split(' ')[0] : '';
    });
  }

  Future<void> _sendOtp() async {
    // TODO: Uncomment the following code when the real API is ready
    // try {
    //   final response = await ApiService.sendOtp(_countryCode, _phoneNumber);
    //   if (response['message'] != null) {
    //     _navigateToVerifyOtp();
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error sending OTP: $e')),
    //   );
    // }

    // Mock API call for testing
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay
    _navigateToVerifyOtp();
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
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
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
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
                if (_showScrollIndicator)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showScrollIndicator ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
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