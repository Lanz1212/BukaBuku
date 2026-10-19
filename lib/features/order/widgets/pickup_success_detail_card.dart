import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PickupSuccessDetailCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String cashierName;
  final String pickupTime;
  final String totalAmount;
  final String paymentMethod;

  const PickupSuccessDetailCard({
    super.key,
    this.orderId = '#ORD00125',
    this.customerName = 'Budi Santoso',
    this.cashierName = 'Siti (Kasir 1 - Cikini)',
    this.pickupTime = '12 Mei 2024, 16:45 WIB',
    this.totalAmount = 'Rp181.000',
    this.paymentMethod = 'Lunas via QRIS',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Status Badge Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selesai (Diambil di Toko)',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'VERIFIED',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSecondaryFixed,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detail rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'Nomor Pesanan',
                  valueWidget: Text(
                    orderId,
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  label: 'Nama Customer',
                  valueWidget: Text(
                    customerName,
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  label: 'Petugas Kasir',
                  valueWidget: Text(
                    cashierName,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  label: 'Waktu Pengambilan',
                  valueWidget: Text(
                    pickupTime,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total Transaction Row Highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Transaksi',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      paymentMethod,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  totalAmount,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        valueWidget,
      ],
    );
  }
}
