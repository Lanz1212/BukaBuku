import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Store Description & Story Narrative Card
class StoreDescriptionCard extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  const StoreDescriptionCard({
    super.key,
    required this.controller,
    this.maxLength = 300,
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
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_stories_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Deskripsi & Narasi Gerai',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  return Text(
                    '${value.text.length} / $maxLength',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-line Text Area
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
              maxLength: maxLength,
              maxLines: 4,
              onChanged: onChanged,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 13,
                height: 1.45,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                counterText: '',
                hintText: 'Tuliskan deskripsi ringkas mengenai gerai fisik...',
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Narasi ini muncul di kartu beranda dan rincian kontak pembaca.',
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
