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
import 'package:connectivity_plus/connectivity_plus.dart'; // Ensure this import is present
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontapp/features/interview/presentation/screens/interview_screen.dart';
import 'package:frontapp/features/interview/presentation/bloc/interview_bloc.dart';
import 'package:frontapp/features/interview/domain/repositories/interview_repository.dart';
import 'package:logger/logger.dart';
import 'package:frontapp/features/auth/presentation/screens/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isNewUser;

  const HomeScreen({Key? key, this.isNewUser = false}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();
  String _userName = '';
  final AdService _adService = AdService();
  late Stream<List<ConnectivityResult>> _connectivityStream; // Change to List
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    _connectivityStream = Connectivity().onConnectivityChanged; // Stream<List<ConnectivityResult>>
    _connectivityStream.listen(_updateConnectionStatus);
    _checkInitialConnection(); // Check initial connection
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _checkInitialConnection() async {
    final List<ConnectivityResult> results = await (Connectivity().checkConnectivity());
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected = results.isNotEmpty && (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi));
    });
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection.')),
      );
    } else {
      _fetchUserProfile(); // Fetch profile when connection is restored
      _adService.loadLargeBannerAd();
      _adService.loadInterstitialAd();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUserProfile(); // Fetch profile when app is resumed
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _apiService.getProfile();
      _logger.d('Received profile data in HomeScreen: $profile');
      
      if (mounted) {
        setState(() {
          _userName = profile['user']?['name']?.toString().trim() ?? 'User';
          _logger.i('Updated username to: $_userName');
        });
      }
    } catch (e) {
      _logger.e('Error fetching user profile: $e');
      if (e.toString().contains('401')) {
        await _apiService.clearToken();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _adService.dispose();
    super.dispose();
  }

  void _shareApp() {
    final String appName = "Speakjar: A platform where you can Speak English Confidently";
    final String playStoreLink = "https://play.google.com/store/apps/details?com.speakenglishwithconfidence.buddy";
    
    final String message = "Check out $appName!\n\n"
        "Download for Android: $playStoreLink";

    Share.share(message, subject: "Check out $appName!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF010101),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuButton(),
                  _buildGreeting(),
                  _buildProfileAvatar(),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Title with Gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Speak English\nConfidently,',
                        style: GoogleFonts.poppins(
                          fontSize: 35,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Enhanced Feature Grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          _buildFeatureButton('Speak with AI', Color(0xFFC6F432), Icons.record_voice_over, true),
                          _buildFeatureButton('Interview AI', Color(0xFF7B61FF), Icons.business, false),
                          _buildFeatureButton('Learn with AI', Color(0xFFC09FF8), Icons.school, false),
                          _buildFeatureButton('Role play ideas', Color(0xFFFFB341), Icons.lightbulb, false),
                          _buildFeatureButton('Rapid Sentence', Color(0xFFFEC4DD), Icons.qr_code, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFC6F432).withOpacity(0.2),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.share, 'Share', false),
            _buildNavItem(Icons.headphones, 'Help', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () => Navigator.of(context).push(NavigationUtils.createSettingsRoute()),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFFC6F432),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/iconai.png'),
        radius: 18,
      ),
    );
  }

  Widget _buildFeatureButton(String label, Color color, IconData icon, bool isMain) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: () => _handleFeatureTap(label),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hi, ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          _userName.isNotEmpty ? _userName : 'User',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          ' 👋',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case 'Share':
            _shareApp();
            break;
          case 'Help':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpScreen()),
            );
            break;
          default:
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.black.withOpacity(isSelected ? 1 : 0.5),
            size: 24,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black.withOpacity(isSelected ? 1 : 0.5),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFeatureTap(String label) async {
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
    } else if (label == 'Interview AI') {
      await _adService.showInterstitialAd();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => InterviewBloc(
              repository: InterviewRepository(_apiService),
            ),
            child: InterviewScreen(),
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
  }
}
