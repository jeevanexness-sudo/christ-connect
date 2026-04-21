import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final Color  bgColor;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size    = 42,
    this.bgColor = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        color:  bgColor.withOpacity(0.22),
        shape:  BoxShape.circle,
        border: Border.all(color: bgColor.withOpacity(0.4), width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.nunito(
            fontSize:   size * 0.32,
            fontWeight: FontWeight.w800,
            color:      bgColor,
          ),
        ),
      ),
    );
  }
}
