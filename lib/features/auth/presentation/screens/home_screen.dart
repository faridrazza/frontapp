import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/speak_with_ai/presentation/screens/speak_with_ai_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontapp/features/speak_with_ai/presentation/bloc/speak_with_ai_bloc.dart';
import 'package:frontapp/features/speak_with_ai/domain/repositories/speak_with_ai_repository.dart';
import 'package:frontapp/core/services/websocket_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/rapid_translation/presentation/bloc/rapid_translation_bloc.dart';
import 'package:frontapp/features/rapid_translation/presentation/screens/rapid_translation_game_screen.dart';
import 'package:frontapp/core/utils/navigation_utils.dart';
import 'package:frontapp/features/settings/presentation/screens/help_screen.dart';
import 'package:frontapp/features/settings/presentation/screens/role_play_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontapp/features/settings/presentation/screens/reminder_screen.dart';
import 'package:frontapp/core/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:frontapp/features/learn_with_ai/presentation/screens/learn_with_ai_screen.dart';
import 'package:frontapp/features/learn_with_ai/presentation/bloc/learn_with_ai_bloc.dart';

class HomeScreen extends StatefulWidget {
  final bool isNewUser;

  const HomeScreen({Key? key, this.isNewUser = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdService _adService = AdService();
  final ApiService _apiService = ApiService();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _adService.loadLargeBannerAd();
    _adService.loadInterstitialAd();
    _fetchUserProfile(); // Fetch user profile immediately after initialization
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _apiService.getProfile();
      setState(() {
        _userName = profile['name'] ?? 'User';
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  void _shareApp() {
    final String appName = "Speak English Confidently";
    final String appStoreLink = "https://apps.apple.com/app/your-app-id";
    final String playStoreLink = "https://play.google.com/store/apps/details?com.speakenglishwithconfidence.buddy";
    
    final String message = "Check out $appName!\n\n"
        "Download for iOS: $appStoreLink\n"
        "Download for Android: $playStoreLink";

    Share.share(message, subject: "Check out $appName!");
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010101),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(NavigationUtils.createSettingsRoute());
                    },
                    child: Icon(Icons.menu, color: Colors.white, size: 24),
                  ),
                  Text(
                    'Hi, $_userName 👋',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/profile.png'),
                    radius: 16,
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Speak English\nConfidently,',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 183 / 104,
                      children: [
                        _buildFeatureButton('Speak with AI', Color(0xFFC6F432), Icons.record_voice_over),
                        _buildFeatureButton('Learn with AI', Color(0xFFC09FF8), Icons.school),
                        _buildFeatureButton('Role play ideas', Color(0xFFFFB341), Icons.lightbulb),
                        _buildFeatureButton('Rapid Sentence', Color(0xFFFEC4DD), Icons.qr_code),
                      ],
                    ),
                    SizedBox(height: 24), // Add padding before the ad
                    if (_adService.isLargeBannerAdReady)
                      Container(
                        alignment: Alignment.center,
                        width: _adService.largeBannerAd!.size.width.toDouble(),
                        height: _adService.largeBannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _adService.largeBannerAd!),
                      ),
                    Spacer(), // This will push the ad up, filling the remaining space
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFC6F432),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'Home', true),
                  _buildNavItem(Icons.notifications_none, 'Reminder', false),
                  _buildNavItem(Icons.share, 'Share', false, onTap: _shareApp),
                  _buildNavItem(Icons.headphones, 'Help', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (label == 'Speak with AI') {
          await _adService.showInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => SpeakWithAIBloc(
                  SpeakWithAIRepository(
                    ApiService(),
                    WebSocketService(),
                  ),
                ),
                child: SpeakWithAIScreen(),
              ),
            ),
          );
        } else if (label == 'Learn with AI') {
          await _adService.showInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => LearnWithAiBloc(ApiService()),
                child: LearnWithAiScreen(),
              ),
            ),
          );
        } else if (label == 'Rapid Sentence') {
          await _adService.showInterstitialAd();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RapidTranslationGameScreen(
                targetLanguage: 'en-US', // Replace with the appropriate language code
              ),
            ),
          );
        } else if (label == 'Role play ideas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RolePlayScreen(),
            ),
          );
        }
        // Add other feature navigations here when implemented
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.arrow_forward, size: 20, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
        if (label == 'Help') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HelpScreen(),
            ),
          );
        } else if (label == 'Reminder') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReminderScreen(),
            ),
          );
        }
        // Add other navigation logic for other items if needed
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
              size: 24,
            ),
          ),
          SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
