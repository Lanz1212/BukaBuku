import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Section Header for Admin Profile and Settings
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMd.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 12,
        ),
      ),
    );
  }
}
