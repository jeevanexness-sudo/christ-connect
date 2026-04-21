import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/auth_provider.dart' as ap;
import 'phone_auth_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const _LoginHeader(),
              const _DividerLine(text: 'Choose how to continue'),
              const SizedBox(height: 8),
              const _GoogleSignInButton(),
              const SizedBox(height: 14),
              const _PhoneSignInButton(),
              const SizedBox(height: 32),
              const _VerseFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header with logo ─────────────────────────────────────────────────────
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
      decoration: const BoxDecoration(
        gradient: AppColors.authGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App icon
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2356), Color(0xFF152E6A)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 8))],
            ),
            child: Stack(alignment: Alignment.center, children: [
              for (final r in [28.0, 44.0, 58.0])
                Container(
                  width: r, height: r,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.blue.withOpacity(0.2))),
                ),
              const Icon(Icons.add_rounded, color: AppColors.gold, size: 44),
            ]),
          ),
          const SizedBox(height: 20),
          Text('Christ', style: AppTextStyles.authTitle.copyWith(height: 1.0)),
          Text('Connect', style: AppTextStyles.authTitle.copyWith(color: AppColors.gold, height: 1.1)),
          const SizedBox(height: 8),
          Text(
            'Your complete Christian ecosystem',
            style: AppTextStyles.authSubtitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Feature pills
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: ['📖 Bible', '🎵 Worship', '👥 Community', '📚 Courses', '❤️ Matrimony']
                .map((t) => _FeaturePill(text: t)).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String text;
  const _FeaturePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border2),
      ),
      child: Text(text, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────
class _DividerLine extends StatelessWidget {
  final String text;
  const _DividerLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(children: [
        const Expanded(child: Divider(color: AppColors.border2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: AppTextStyles.caption),
        ),
        const Expanded(child: Divider(color: AppColors.border2)),
      ]),
    );
  }
}

// ─── Google Sign In Button ────────────────────────────────────────────────
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(
      builder: (ctx, auth, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Error message
              if (auth.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(auth.error!, style: AppTextStyles.body2.copyWith(color: AppColors.danger))),
                    GestureDetector(onTap: auth.clearError, child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 16)),
                  ]),
                ),
              ],
              // Google button
              GestureDetector(
                onTap: auth.isLoading ? null : () async {
                  final ok = await auth.signInWithGoogle();
                  if (!ok && ctx.mounted && auth.error == null) {
                    // cancelled — do nothing
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border2),
                  ),
                  child: auth.isLoading
                      ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5)))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _GoogleLogo(),
                          const SizedBox(width: 12),
                          Text('Continue with Google', style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                        ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22, height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    // Simplified G icon using colored arcs
    final colors = [AppColors.googleRed, const Color(0xFFFBBC05), const Color(0xFF34A853), AppColors.blue];
    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r - 1), (i * 90 - 45) * 3.14159 / 180, 80 * 3.14159 / 180, false, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Phone Sign In Button ─────────────────────────────────────────────────
class _PhoneSignInButton extends StatelessWidget {
  const _PhoneSignInButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PhoneAuthScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.blueGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Continue with Phone OTP', style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
          ]),
        ),
      ),
    );
  }
}

// ─── Footer verse ─────────────────────────────────────────────────────────
class _VerseFooter extends StatelessWidget {
  const _VerseFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(children: [
        Text('"Where two or three gather in my name, there am I with them."', style: AppTextStyles.body2.copyWith(fontStyle: FontStyle.italic, height: 1.6), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('Matthew 18:20', style: AppTextStyles.goldLabel),
        const SizedBox(height: 20),
        Text('By continuing, you agree to our Terms of Service and Privacy Policy.', style: AppTextStyles.caption.copyWith(fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }
}
