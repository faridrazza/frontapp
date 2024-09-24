import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/auth/presentation/widgets/ai_orb.dart';
import 'package:frontapp/features/auth/presentation/widgets/phone_input_field.dart';
import 'package:frontapp/features/auth/presentation/widgets/wave_background.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({Key? key}) : super(key: key);

  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  String _phoneNumber = '';
  bool _isValid = false;

  void _updatePhoneNumber(String number, bool isValid) {
    setState(() {
      _phoneNumber = number;
      _isValid = isValid;
    });
  }

  void _submitPhoneNumber() {
    if (_isValid) {
      // TODO: Implement phone number submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitting phone number: $_phoneNumber')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
    }
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
                  onPressed: _submitPhoneNumber,
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
                PhoneInputField(onInputChanged: _updatePhoneNumber),
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