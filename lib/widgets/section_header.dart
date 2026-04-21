import 'package:flutter/material.dart';
import '../core/app_text_styles.dart';
import '../core/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.gold, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}
