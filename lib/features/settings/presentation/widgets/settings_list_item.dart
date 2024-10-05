import 'package:flutter/material.dart';
import 'package:frontapp/features/settings/domain/models/settings_item.dart';

class SettingsListItem extends StatelessWidget {
  final SettingsItem item;

  const SettingsListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(item.icon, color: Colors.white),
            SizedBox(width: 16),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}