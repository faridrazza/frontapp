import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:frontapp/core/theme/app_theme.dart';

class PhoneInputField extends StatelessWidget {
  final Function(String, bool) onInputChanged;

  const PhoneInputField({Key? key, required this.onInputChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) {
          // We'll consider the number valid if it's not empty
          bool isValid = number.phoneNumber?.isNotEmpty ?? false;
          onInputChanged(number.phoneNumber ?? '', isValid);
        },
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DROPDOWN,
        ),
        ignoreBlank: false,
        autoValidateMode: AutovalidateMode.onUserInteraction,
        selectorTextStyle: const TextStyle(color: AppTheme.textColor),
        textStyle: const TextStyle(color: AppTheme.textColor),
        inputDecoration: const InputDecoration(
          hintText: 'Phone Number',
          hintStyle: TextStyle(color: AppTheme.textColor),
          border: InputBorder.none,
        ),
      ),
    );
  }
}