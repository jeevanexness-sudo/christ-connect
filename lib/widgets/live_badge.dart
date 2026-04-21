import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
            color: AppColors.danger, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('LIVE', style: GoogleFonts.nunito(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: AppColors.danger, letterSpacing: 0.5)),
      ]),
    );
  }
}
