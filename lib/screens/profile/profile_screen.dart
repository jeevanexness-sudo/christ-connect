import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';
import '../courses/courses_screen.dart';
import '../matrimony/matrimony_screen.dart';
import '../community/community_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Profile Screen — Fetches real user data from Firestore
// ═══════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool       _loading = true;
  String?    _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ── Fetch user from Firestore using current Auth UID ─────────────────────
  Future<void> _loadUser() async {
    setState(() { _loading = true; _error = null; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() { _error = 'Not logged in.'; _loading = false; });
        return;
      }
      final user = await FirestoreService.instance.getUser(uid);
      if (!mounted) return;
      setState(() {
        _user    = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = 'Failed to load profile. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: _loading
            ? const _LoadingView()
            : _error != null
                ? _ErrorView(error: _error!, onRetry: _loadUser)
                : _ProfileContent(user: _user),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Loading View
// ═══════════════════════════════════════════════════════════════════════════
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border2),
          ),
          child: const CircularProgressIndicator(
            color: AppColors.gold, strokeWidth: 2.5,
          ).withPadding(const EdgeInsets.all(28)),
        ),
        const SizedBox(height: 20),
        Text('Loading profile…', style: AppTextStyles.body2),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error View
// ═══════════════════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String       error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 34),
          ),
          const SizedBox(height: 16),
          Text('Oops!', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(error, style: AppTextStyles.body2, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GoldButton(label: 'Try Again', onTap: onRetry, width: 140),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Main Profile Content
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileContent extends StatelessWidget {
  final UserModel? user;
  const _ProfileContent({required this.user});

  static const _menuItems = <_MenuItem>[
    _MenuItem('My Reading Plan',  Icons.menu_book_outlined,       AppColors.blue),
    _MenuItem('Saved Songs',      Icons.music_note_outlined,      AppColors.violet),
    _MenuItem('Prayer Journal',   Icons.book_outlined,            AppColors.gold),
    _MenuItem('My Church',        Icons.church_outlined,          AppColors.success),
    _MenuItem('Courses',          Icons.school_outlined,          AppColors.blue),
    _MenuItem('Matrimony',        Icons.favorite_border_rounded,  AppColors.pink),
    _MenuItem('Community',        Icons.people_outline_rounded,   AppColors.gold),
    _MenuItem('Notifications',    Icons.notifications_outlined,   AppColors.muted),
    _MenuItem('Account Settings', Icons.settings_outlined,        AppColors.muted),
  ];

  void _onMenuTap(BuildContext ctx, String label) {
    switch (label) {
      case 'Courses':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CoursesScreen()));
        break;
      case 'Matrimony':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const MatrimonyScreen()));
        break;
      case 'Community':
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CommunityScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        // ── Header gradient banner ──────────────────────────────────────────
        _ProfileBanner(user: user),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: K.pad),
          child: Column(children: [
            const SizedBox(height: 20),

            // ── User info card ──────────────────────────────────────────────
            _InfoCard(user: user),
            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────────
            _StatsRow(),
            const SizedBox(height: 24),

            // ── Menu items ─────────────────────────────────────────────────
            ..._menuItems.map((m) => _MenuRow(
              item:  m,
              onTap: () => _onMenuTap(context, m.label),
            )),

            const SizedBox(height: 24),

            // ── Sign out ───────────────────────────────────────────────────
            _SignOutButton(),
            const SizedBox(height: 40),
          ]),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Profile Banner — gradient top section with avatar
// ═══════════════════════════════════════════════════════════════════════════
class _ProfileBanner extends StatelessWidget {
  final UserModel? user;
  const _ProfileBanner({required this.user});

  @override
  Widget build(BuildContext context) {
    final name     = user?.displayName ?? 'Believer';
    final initials = user?.initials    ?? 'U';
    final photoUrl = user?.photoUrl;
    final method   = user?.loginMethod ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Color(0xFF0C1A38), AppColors.bgDark],
        ),
      ),
      child: Column(children: [
        // Avatar
        Stack(alignment: Alignment.bottomRight, children: [
          // Photo or initials circle
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                colors: [Color(0xFF1D3A7A), Color(0xFF2B5CE6)],
              ),
              border: Border.all(color: AppColors.gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color:       AppColors.gold.withOpacity(0.2),
                  blurRadius:  20,
                  offset:      const Offset(0, 6),
                ),
              ],
            ),
            child: photoUrl != null && photoUrl.isNotEmpty
                ? ClipOval(child: Image.network(photoUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _InitialsText(initials: initials)))
                : _InitialsText(initials: initials),
          ),
          // Edit icon
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color:  AppColors.gold,
              shape:  BoxShape.circle,
              border: Border.all(color: AppColors.bgDark, width: 2),
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.black, size: 14),
          ),
        ]),

        const SizedBox(height: 14),
        Text(name, style: AppTextStyles.heading2),
        const SizedBox(height: 6),

        // Login method badge
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (method == 'google') ...[
            CCBadge(text: '🔵 Google', color: AppColors.blue),
            const SizedBox(width: 8),
          ],
          if (method == 'phone') ...[
            CCBadge(text: '📱 Phone', color: AppColors.violet),
            const SizedBox(width: 8),
          ],
          CCBadge(text: '✓ Verified', color: AppColors.success),
        ]),

        const SizedBox(height: 24),
      ]),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String initials;
  const _InitialsText({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(initials,
        style: GoogleFonts.nunito(
          fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.white)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// User Info Card — name, email, phone, denomination
// ═══════════════════════════════════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final UserModel? user;
  const _InfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(children: [
        _InfoRow(
          icon:  Icons.person_outline_rounded,
          label: 'Name',
          value: user?.name.isNotEmpty == true ? user!.name : 'Not set',
          color: AppColors.blue,
        ),
        const Divider(height: 1, color: AppColors.border),
        _InfoRow(
          icon:  Icons.email_outlined,
          label: 'Email',
          value: user?.email.isNotEmpty == true ? user!.email : '—',
          color: AppColors.violet,
        ),
        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon:  Icons.phone_outlined,
            label: 'Phone',
            value: user!.phone!,
            color: AppColors.success,
          ),
        ],
        if (user?.denomination != null) ...[
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon:  Icons.church_outlined,
            label: 'Denomination',
            value: user!.denomination!,
            color: AppColors.gold,
          ),
        ],
        if (user?.location != null) ...[
          const Divider(height: 1, color: AppColors.border),
          _InfoRow(
            icon:  Icons.location_on_outlined,
            label: 'Location',
            value: user!.location!,
            color: AppColors.pink,
          ),
        ],
        const Divider(height: 1, color: AppColors.border),
        _InfoRow(
          icon:  Icons.login_rounded,
          label: 'Login via',
          value: _loginLabel(user?.loginMethod),
          color: AppColors.muted,
        ),
      ]),
    );
  }

  String _loginLabel(String? method) {
    switch (method) {
      case 'google': return 'Google Account';
      case 'phone':  return 'Phone OTP';
      default:       return 'Email';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  const _InfoRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.overline),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Stats Row
// ═══════════════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: StatCard(number: '18/30', label: 'Day Streak')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(number: '42',    label: 'Prayers')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(number: '3',     label: 'Courses')),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Menu Item
// ═══════════════════════════════════════════════════════════════════════════
class _MenuItem {
  final String   label;
  final IconData icon;
  final Color    color;
  const _MenuItem(this.label, this.icon, this.color);
}

class _MenuRow extends StatelessWidget {
  final _MenuItem    item;
  final VoidCallback onTap;
  const _MenuRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap:       onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(item.label,
                style: AppTextStyles.bodyBold.copyWith(fontSize: 14))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ]),
        ),
      ),
      const Divider(height: 1, color: AppColors.border),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sign Out Button
// ═══════════════════════════════════════════════════════════════════════════
class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withOpacity(0.4)),
          color: AppColors.danger.withOpacity(0.05),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Text('Sign Out',
              style: AppTextStyles.buttonSecondary.copyWith(color: AppColors.danger)),
        ]),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to sign out of Christ Connect?',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.goldLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ap.AuthProvider>().signOut();
            },
            child: Text('Sign Out',
                style: AppTextStyles.body2.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Helper extension ──────────────────────────────────────────────────────
extension WidgetPadding on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}
