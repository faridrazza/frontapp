import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontapp/core/theme/app_theme.dart';
import 'package:frontapp/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:frontapp/features/auth/presentation/screens/home_screen.dart';
import 'package:frontapp/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontapp/core/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    debug: true, // Set to false in production
  );
  
  await MobileAds.instance.initialize();
  
  final apiService = ApiService();
  await apiService.initializeToken();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinking();
  }

  Future<void> _initDeepLinking() async {
    _appLinks = AppLinks();

    try {
      // Handle app start from deep link
      final uri = await _appLinks.getInitialLink();
      print('Initial URI: $uri');
      if (uri != null) {
        _handleDeepLink(uri);
      }

      // Handle links when app is running
      _subscription = _appLinks.uriLinkStream.listen(
        (uri) {
          print('Received URI: $uri');
          _handleDeepLink(uri);
        },
        onError: (err) => print('Deep link error: $err'),
      );
    } catch (e) {
      print('Deep linking initialization error: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Processing deep link: $uri');
    
    if (uri.scheme == 'speakjar' && uri.host == 'reset-password') {
      // No need to extract token as Supabase handles the session
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResetPasswordScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'English Speaking AI',
      theme: AppTheme.theme,
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      setState(() {
        _isLoggedIn = token != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC6F432),
          ),
        ),
      );
    }
    
    return _isLoggedIn ? const HomeScreen(isNewUser: false) : const SignUpScreen();
  }
}
