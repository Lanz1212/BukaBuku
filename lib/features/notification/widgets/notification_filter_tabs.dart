import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/notification_model.dart';

class NotificationFilterTabs extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final ValueChanged<NotificationCategory> onCategoryChanged;

  const NotificationFilterTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildFilterChip(
            category: NotificationCategory.all,
            label: 'Semua',
            hasDot: true,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            category: NotificationCategory.order,
            label: 'Pesanan & Pengambilan',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            category: NotificationCategory.promo,
            label: 'Promo Buku',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required NotificationCategory category,
    required String label,
    bool hasDot = false,
  }) {
    final isSelected = selectedCategory == category;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategoryChanged(category),
        borderRadius: BorderRadius.circular(9999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (hasDot && isSelected) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
