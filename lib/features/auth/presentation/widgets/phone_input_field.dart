import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneInputField extends StatelessWidget {
  final Function(String, bool) onInputChanged;

  const PhoneInputField({Key? key, required this.onInputChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          bool isValid = number.phoneNumber?.isNotEmpty ?? false;
          onInputChanged(number.phoneNumber ?? '', isValid);
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.disabled,
        selectorTextStyle: const TextStyle(color: Colors.white),
        textStyle: const TextStyle(color: Colors.white),
        inputDecoration: const InputDecoration(
          hintText: 'Phone Number',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}