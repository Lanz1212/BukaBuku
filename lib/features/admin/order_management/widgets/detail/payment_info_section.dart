import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../models/admin_order_detail.dart';
import 'detail_section_card.dart';

class PaymentInfoSection extends StatelessWidget {
  final AdminOrderDetail order;

  const PaymentInfoSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final methodTitle = order.paymentMethod.contains('QRIS')
        ? 'Online QRIS'
        : order.paymentMethod.split('•').first.trim();
    final methodSub = order.paymentChannel ??
        (order.paymentMethod.contains('QRIS')
            ? 'BCA / GoPay Instan'
            : (order.paymentMethod.contains('Transfer')
                ? 'Bank Transfer'
                : 'Tunai di Kasir'));

    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Rincian Pembayaran',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two-column payment details
          Row(
            children: [
              // Left: Method
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Metode Pembayaran',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        methodTitle,
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        methodSub,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Right: Status
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Transaksi',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            order.isPaid
                                ? Icons.check_circle_outline_rounded
                                : Icons.schedule_rounded,
                            size: 13,
                            color: order.isPaid
                                ? const Color(0xFF5A4A35)
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.isPaid ? 'Lunas' : 'Menunggu',
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: order.isPaid
                                  ? const Color(0xFF5A4A35)
                                  : AppColors.warning,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.isPaid ? 'Auto-verified' : 'Menunggu kasir',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cashier Validation Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF8C5C33),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.isPaid
                        ? 'Tidak perlu penagihan tunai di kasir. Cukup validasi fisik dan pindai QR Pickup pelanggan.'
                        : 'Mohon lakukan penagihan tunai di meja kasir sebelum menyerahkan pesanan kepada pembeli.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
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
