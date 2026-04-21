import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CCProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;

  const CCProgressBar({
    super.key,
    required this.value,
    this.height = 4,
    this.color,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, bc) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: trackColor ?? AppColors.border,
          borderRadius: BorderRadius.circular(height),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? AppColors.gold,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      );
    });
  }
}
