import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const GoldButton({
    super.key,
    required this.label,
    this.onTap,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border2),
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonSecondary),
      ),
    );
  }
}

class CCIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final Color? bgColor;

  const CCIconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 38,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.white, size: size * 0.44),
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? activeColor;

  const FilterPill({
    super.key,
    required this.label,
    required this.isActive,
    this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = activeColor ?? AppColors.gold;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? c : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? c : AppColors.border2),
        ),
        child: Text(label,
          style: GoogleFonts.nunito(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: isActive ? Colors.black : AppColors.muted)),
      ),
    );
  }
}
