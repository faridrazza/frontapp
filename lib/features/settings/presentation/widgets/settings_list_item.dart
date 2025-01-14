import 'package:flutter/material.dart';
import 'package:frontapp/features/settings/domain/models/settings_item.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsListItem extends StatelessWidget {
  final SettingsItem item;

  const SettingsListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLogout = item.title.toLowerCase() == 'logout';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLogout ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () => item.onTap(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLogout 
                      ? Colors.red.withOpacity(0.1) 
                      : Color(0xFFC6F432).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: isLogout ? Colors.red : Color(0xFFC6F432),
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Text(
                item.title,
                style: GoogleFonts.poppins(
                  color: isLogout ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Spacer(),
              if (!isLogout)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white60,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}