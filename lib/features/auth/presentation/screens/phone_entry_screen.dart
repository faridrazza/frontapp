import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/auth/presentation/widgets/ai_orb.dart';
import 'package:frontapp/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:frontapp/features/auth/presentation/widgets/wave_background.dart';
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
      body: WaveBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Improve Your\nEnglish speaking\nskills with AI',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const Expanded(child: AiOrb()),
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
                      color: _isValid ? Colors.black : Colors.black,
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
      ),
    );
  }
}