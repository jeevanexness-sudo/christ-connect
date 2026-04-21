import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

// ─── CCBadge ──────────────────────────────────────────────────────────────
class CCBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const CCBadge({super.key, required this.text, this.color = AppColors.gold, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: color, fontSize: fontSize)),
    );
  }
}

// ─── SectionHeader ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: AppTextStyles.sectionTitle),
      if (actionLabel != null)
        GestureDetector(onTap: onAction, child: Text(actionLabel!, style: AppTextStyles.body2.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600))),
    ]);
  }
}

// ─── CCCard ───────────────────────────────────────────────────────────────
class CCCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;
  const CCCard({super.key, required this.child, this.padding, this.onTap, this.color, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.cardDark,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.gold.withOpacity(0.05),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), border: Border.all(color: AppColors.border)),
          child: child,
        ),
      ),
    );
  }
}

// ─── GradientCard ─────────────────────────────────────────────────────────
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry? padding;
  const GradientCard({super.key, required this.child, required this.gradient, this.borderColor, this.radius = 20, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(radius),
          border: borderColor != null ? Border.all(color: borderColor!) : null),
      child: child,
    );
  }
}

// ─── AvatarCircle ─────────────────────────────────────────────────────────
class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Color bgColor;
  final String? photoUrl;
  const AvatarCircle({super.key, required this.initials, this.size = 42, this.bgColor = AppColors.blue, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(radius: size / 2, backgroundImage: NetworkImage(photoUrl!));
    }
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bgColor.withOpacity(0.22), shape: BoxShape.circle, border: Border.all(color: bgColor.withOpacity(0.4))),
      child: Center(child: Text(initials, style: GoogleFonts.nunito(fontSize: size * 0.32, fontWeight: FontWeight.w800, color: bgColor))),
    );
  }
}

// ─── CCProgressBar ────────────────────────────────────────────────────────
class CCProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  const CCProgressBar({super.key, required this.value, this.height = 4, this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, bc) {
      return Container(
        height: height,
        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(height)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(decoration: BoxDecoration(color: color ?? AppColors.gold, borderRadius: BorderRadius.circular(height))),
          ),
        ),
      );
    });
  }
}

// ─── GoldButton ───────────────────────────────────────────────────────────
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  const GoldButton({super.key, required this.label, this.onTap, this.width, this.padding, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
            : Text(label, textAlign: TextAlign.center, style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}

// ─── OutlineButton2 ───────────────────────────────────────────────────────
class OutlineButton2 extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? width;
  const OutlineButton2({super.key, required this.label, this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: AppColors.card2, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border2)),
        child: Text(label, textAlign: TextAlign.center, style: AppTextStyles.buttonSecondary),
      ),
    );
  }
}

// ─── CCIconBtn ────────────────────────────────────────────────────────────
class CCIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  const CCIconBtn({super.key, required this.icon, this.onTap, this.size = 38, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Icon(icon, color: iconColor ?? AppColors.white, size: size * 0.44),
      ),
    );
  }
}

// ─── FilterPill ───────────────────────────────────────────────────────────
class FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const FilterPill({super.key, required this.label, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.gold : AppColors.border2),
        ),
        child: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? Colors.black : AppColors.muted)),
      ),
    );
  }
}

// ─── StatCard ─────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String number;
  final String label;
  const StatCard({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(children: [Text(number, style: AppTextStyles.goldHeading), const SizedBox(height: 3), Text(label, style: AppTextStyles.overline)]),
    );
  }
}

// ─── LiveBadge ────────────────────────────────────────────────────────────
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('LIVE', style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.danger)),
      ]),
    );
  }
}

// ─── PlayButton ───────────────────────────────────────────────────────────
class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;
  final double size;
  const PlayButton({super.key, required this.isPlaying, this.onTap, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
        child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: size * 0.5),
      ),
    );
  }
}
