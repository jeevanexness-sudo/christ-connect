import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'providers/auth_provider.dart' as ap;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {}

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness:     Brightness.dark,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => ap.AuthProvider(),
      child:  const ChristConnectApp(),
    ),
  );
}

class ChristConnectApp extends StatelessWidget {
  const ChristConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                    'Christ Connect',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _scale = Tween(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _opacity = Tween(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

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
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end:   Alignment.bottomRight,
                      colors: [Color(0xFF0F2356), Color(0xFF152E6A)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.35), width: 1.5),
                    boxShadow: [BoxShadow(
                      color: AppColors.gold.withOpacity(0.2),
                      blurRadius: 50, offset: const Offset(0, 14),
                    )],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    for (final r in [32.0, 52.0, 70.0])
                      Container(
                        width: r, height: r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.blue.withOpacity(0.22)),
                        ),
                      ),
                    const Icon(Icons.add_rounded,
                        color: AppColors.gold, size: 50),
                  ]),
                ),
                const SizedBox(height: 26),
                Text('Christ',
                    style: GoogleFonts.nunito(
                      fontSize: 36, fontWeight: FontWeight.w800,
                      color: AppColors.white, height: 1.0)),
                Text('Connect',
                    style: GoogleFonts.nunito(
                      fontSize: 36, fontWeight: FontWeight.w800,
                      color: AppColors.gold, height: 1.1)),
                const SizedBox(height: 10),
                Text('Your complete Christian ecosystem',
                    style: GoogleFonts.nunito(
                      fontSize: 13, color: AppColors.muted,
                      fontWeight: FontWeight.w500)),
                const SizedBox(height: 44),
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
