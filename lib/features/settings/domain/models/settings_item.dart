import 'package:flutter/material.dart';

class SettingsItem {
  final String title;
  final IconData icon;
  final Function onTap;

  SettingsItem({required this.title, required this.icon, required this.onTap});
}