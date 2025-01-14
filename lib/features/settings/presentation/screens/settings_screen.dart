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
            _showErrorSnackBar(context, 'Failed to fetch profile: $e');
          }
        },
      ),
      SettingsItem(
        title: 'Report a problem',
        icon: Icons.flag,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ReportProblemScreen()),
          );
        },
      ),
      SettingsItem(
        title: 'Logout',
        icon: Icons.logout,
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  Color(0xFF1A1A1A),
                  Color(0xFF262626),
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar with enhanced styling
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                        ).createShader(bounds),
                        child: Text(
                          'Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Settings List with removed "Account Settings" text
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SettingsContainer(items: settingsItems),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Color(0xFFC6F432),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.red[400],
                  fontWeight: FontWeight.w500,
                ),
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
        _showErrorSnackBar(context, 'Failed to logout: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}