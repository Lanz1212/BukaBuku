import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum PaymentFilter {
  all,
  cash,
  paid,
  pending,
}

class PaymentFilterTabs extends StatelessWidget {
  final PaymentFilter selectedFilter;
  final ValueChanged<PaymentFilter> onFilterChanged;
  final int cashCount;

  const PaymentFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.cashCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterItem(
            filter: PaymentFilter.all,
            label: 'Semua',
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: PaymentFilter.cash,
            label: 'Cash',
            badgeCount: cashCount,
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: PaymentFilter.paid,
            label: 'Paid (Lunas)',
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: PaymentFilter.pending,
            label: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem({
    required PaymentFilter filter,
    required String label,
    int? badgeCount,
  }) {
    final bool isSelected = selectedFilter == filter;

    return InkWell(
      onTap: () => onFilterChanged(filter),
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
            if (badgeCount != null && badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.warning,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
