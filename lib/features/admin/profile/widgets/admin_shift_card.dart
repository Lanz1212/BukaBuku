import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Shift & Fast Cashier Mode Card for Admin Profile
class AdminShiftCard extends StatelessWidget {
  final String storeStatusText;
  final String shiftName;
  final VoidCallback? onOpenCashier;

  const AdminShiftCard({
    super.key,
    this.storeStatusText = 'Toko Buka  (08:00 - 21:00 WIB)',
    this.shiftName = 'Shift Siang',
    this.onOpenCashier,
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
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          // Store Status & Shift Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    storeStatusText,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                shiftName,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cashier Mode Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Kasir Cepat',
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Langsung layani transaksi buku fisik',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onOpenCashier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Buka\nKasir',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.onPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
