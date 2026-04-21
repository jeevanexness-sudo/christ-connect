import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback? onTap;
  final double size;
  final Color? bgColor;

  const PlayButton({
    super.key,
    required this.isPlaying,
    this.onTap,
    this.size = 50,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.gold,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.black,
          size: size * 0.5,
        ),
      ),
    );
  }
}
