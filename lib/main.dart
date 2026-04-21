import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'providers/auth_provider.dart' as ap;
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => ap.AuthProvider(),
      child: const ChristConnectApp(),
    ),
  );
}

class ChristConnectApp extends StatelessWidget {
  const ChristConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Christ Connect',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const AuthWrapper(),
    );
  }
}

// ─── Auth Wrapper ─────────────────────────────────────────────────────────
// Decides whether to show Login or Home screen based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(
      builder: (ctx, auth, _) {
        switch (auth.status) {
          // ── Loading / Unknown ─────────────────────────────────────────────
          case ap.AuthStatus.unknown:
          case ap.AuthStatus.loading:
            return const _SplashScreen();

          // ── Authenticated → Home ──────────────────────────────────────────
          case ap.AuthStatus.authenticated:
            return const MainNavigation();

          // ── Not authenticated → Login ─────────────────────────────────────
          case ap.AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _scale   = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _opacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void initState() { super.initState(); _ctrl.forward(); }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF0F2356), Color(0xFF152E6A)]),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1.5),
                    boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.18), blurRadius: 50, offset: const Offset(0, 14))],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    for (final r in [32.0, 52.0, 70.0])
                      Container(width: r, height: r, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.blue.withOpacity(0.22)))),
                    const Icon(Icons.add_rounded, color: AppColors.gold, size: 50),
                  ]),
                ),
                const SizedBox(height: 26),
                Text('Christ',  style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.white, height: 1.0)),
                Text('Connect', style: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.gold,  height: 1.1)),
                const SizedBox(height: 10),
                Text('Your complete Christian ecosystem', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w500)),
                const SizedBox(height: 40),
                SizedBox(
                  width: 130,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
