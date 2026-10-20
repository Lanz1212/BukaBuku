import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ProfileStatsRow extends StatelessWidget {
  final int orderCount;
  final int favoriteCount;
  final int activeVouchers;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onVouchersTap;

  const ProfileStatsRow({
    super.key,
    required this.orderCount,
    required this.favoriteCount,
    required this.activeVouchers,
    this.onOrdersTap,
    this.onFavoritesTap,
    this.onVouchersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem(
              value: '$orderCount',
              label: 'Pesanan',
              icon: Icons.receipt_long_rounded,
              onTap: onOrdersTap,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
            _buildStatItem(
              value: '$favoriteCount',
              label: 'Buku Favorit',
              icon: Icons.favorite_rounded,
              onTap: onFavoritesTap,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
            _buildStatItem(
              value: '$activeVouchers',
              label: 'Voucher Aktif',
              icon: Icons.confirmation_number_rounded,
              onTap: onVouchersTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.primaryFixed.withValues(alpha: 0.2),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      value,
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
