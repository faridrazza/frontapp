import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneInputField extends StatefulWidget {
  final Function(String, bool) onInputChanged;

  const PhoneInputField({Key? key, required this.onInputChanged}) : super(key: key);

  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  isValid = false;
                });
              },
              onInputValidated: (bool value) {
                setState(() {
                  isValid = value;
                });
                widget.onInputChanged(number.phoneNumber ?? '', value);
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.white),
              textStyle: const TextStyle(color: Colors.white),
              initialValue: number,
              textFieldController: controller,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              inputDecoration: const InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                errorStyle: TextStyle(color: Colors.red),
              ),
              searchBoxDecoration: InputDecoration(
                hintText: 'Search by country name or dial code',
                hintStyle: const TextStyle(color: Colors.white54),
                fillColor: const Color(0xFF282C34),
                filled: true,
                border: InputBorder.none,
              ),
            ),
            if (!isValid && controller.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Invalid phone number',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}