import 'package:flutter/material.dart';
import 'package:frontapp/core/theme/app_theme.dart';
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
      body: WaveBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Improve Your English speaking skill with AI',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const Expanded(child: AiOrb()),
                PhoneInputField(onInputChanged: _updatePhoneNumber),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isValid ? _submitPhoneNumber : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enter Phone Number'),
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