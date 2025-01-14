import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/settings/domain/models/settings_item.dart';
import 'package:frontapp/features/settings/presentation/widgets/settings_container.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:frontapp/features/settings/presentation/screens/report_problem_screen.dart';
import 'package:frontapp/features/auth/presentation/screens/sign_in_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final List<SettingsItem> settingsItems = [
      SettingsItem(
        title: 'Native language',
        icon: Icons.person,
        onTap: () async {
          try {
            final userProfile = await _apiService.getProfile();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(userProfile: userProfile),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to fetch profile: $e')),
            );
          }
        },
      ),
      SettingsItem(
        title: 'Report a problem',
        icon: Icons.flag,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportProblemScreen(),
            ),
          );
        },
      ),
      SettingsItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () async {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900],
                title: Text(
                  'Confirm Logout',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                content: Text(
                  'Are you sure you want to logout?',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: Color(0xFFC6F432)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );

          if (confirm == true) {
            try {
              await _apiService.clearToken();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to logout: $e')),
              );
            }
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        titleSpacing: 0, // This removes the default padding
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SettingsContainer(items: settingsItems),
          ),
        ),
      ),
    );
  }
}