import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../widgets/widgets.dart';
import '../courses/courses_screen.dart';
import '../matrimony/matrimony_screen.dart';
import '../community/community_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _menu = <_MI>[
    _MI('My Reading Plan',   Icons.menu_book_outlined,      AppColors.blue),
    _MI('Saved Songs',       Icons.music_note_outlined,     AppColors.violet),
    _MI('Prayer Journal',    Icons.book_outlined,           AppColors.gold),
    _MI('My Church',         Icons.church_outlined,         AppColors.success),
    _MI('Courses',           Icons.school_outlined,         AppColors.blue),
    _MI('Matrimony',         Icons.favorite_border_rounded, AppColors.pink),
    _MI('Community',         Icons.people_outline_rounded,  AppColors.gold),
    _MI('Notifications',     Icons.notifications_outlined,  AppColors.muted),
    _MI('Account Settings',  Icons.settings_outlined,       AppColors.muted),
  ];

  void _menuAction(BuildContext ctx, String label) {
    switch (label) {
      case 'Courses':   Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CoursesScreen())); break;
      case 'Matrimony': Navigator.push(ctx, MaterialPageRoute(builder: (_) => const MatrimonyScreen())); break;
      case 'Community': Navigator.push(ctx, MaterialPageRoute(builder: (_) => const CommunityScreen())); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(
      builder: (ctx, auth, _) {
        final user = auth.user;
        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: K.pad),
              child: Column(children: [
                const SizedBox(height: 24),
                _buildAvatar(user?.initials ?? 'U', user?.photoUrl, user?.displayName ?? 'Believer', user?.email ?? '', user?.loginMethod ?? ''),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 26),
                ..._menu.map((m) => _MenuRow(item: m, onTap: () => _menuAction(context, m.label))),
                const SizedBox(height: 24),
                _buildSignOut(context, auth),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(String initials, String? photoUrl, String name, String email, String method) {
    return Column(children: [
      AvatarCircle(initials: initials, size: 84, bgColor: AppColors.blue, photoUrl: photoUrl),
      const SizedBox(height: 12),
      Text(name, style: AppTextStyles.heading2),
      const SizedBox(height: 4),
      Text(email.isNotEmpty ? email : 'Phone user', style: AppTextStyles.caption),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: [
        CCBadge(text: '✓  Verified', color: AppColors.success),
        if (method == 'google') CCBadge(text: 'Google', color: AppColors.blue),
        if (method == 'phone')  CCBadge(text: 'Phone', color: AppColors.violet),
      ]),
    ]);
  }

  Widget _buildStats() {
    return Row(children: [
      Expanded(child: StatCard(number: '18/30', label: 'Day Streak')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(number: '42', label: 'Prayers')),
      const SizedBox(width: 10),
      Expanded(child: StatCard(number: '3', label: 'Courses')),
    ]);
  }

  Widget _buildSignOut(BuildContext context, ap.AuthProvider auth) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context, auth),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.danger.withOpacity(0.35)),
        ),
        child: Text('Sign Out', textAlign: TextAlign.center,
            style: AppTextStyles.buttonSecondary.copyWith(color: AppColors.danger)),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, ap.AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: AppTextStyles.heading3),
        content: Text('Are you sure you want to sign out?', style: AppTextStyles.body2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: AppTextStyles.goldLabel)),
          TextButton(
            onPressed: () { Navigator.pop(ctx); auth.signOut(); },
            child: Text('Sign Out', style: AppTextStyles.body2.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _MI {
  final String label;
  final IconData icon;
  final Color color;
  const _MI(this.label, this.icon, this.color);
}

class _MenuRow extends StatelessWidget {
  final _MI item;
  final VoidCallback onTap;
  const _MenuRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(children: [
            Container(width: 38, height: 38,
              decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(item.icon, color: item.color, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(item.label, style: AppTextStyles.bodyBold.copyWith(fontSize: 14))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ]),
        ),
      ),
      const Divider(height: 1, color: AppColors.border),
    ]);
  }
}
