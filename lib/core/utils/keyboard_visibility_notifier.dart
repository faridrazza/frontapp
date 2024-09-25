import 'package:flutter/material.dart';

class KeyboardVisibilityNotifier extends ValueNotifier<bool> {
  KeyboardVisibilityNotifier() : super(false);

  void updateVisibility(bool isVisible) {
    value = isVisible;
  }
}

final keyboardVisibilityNotifier = KeyboardVisibilityNotifier(); 