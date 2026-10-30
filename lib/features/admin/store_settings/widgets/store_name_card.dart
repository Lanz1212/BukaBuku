import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Store Official Name Card
class StoreNameCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const StoreNameCard({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.store_mall_directory_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Nama Toko Resmi',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Input field container
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                hintText: 'Nama Toko Buku...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Ditampilkan di struk belanja, nota digital, dan dashboard pembeli.',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
