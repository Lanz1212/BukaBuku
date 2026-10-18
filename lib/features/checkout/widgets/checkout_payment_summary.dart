import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/checkout_order.dart';

/// Card showing the full payment breakdown: subtotal, shipping fee, service fee,
/// and total payment, with trust reassurance footer.
class CheckoutPaymentSummary extends StatelessWidget {
  final int itemCount;
  final int subtotalValue;
  final FulfillmentMode fulfillmentMode;
  final int shippingFee;
  final int serviceFee;
  final int totalPayment;

  const CheckoutPaymentSummary({
    super.key,
    required this.itemCount,
    required this.subtotalValue,
    required this.fulfillmentMode,
    required this.shippingFee,
    required this.serviceFee,
    required this.totalPayment,
  });

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = fulfillmentMode == FulfillmentMode.pickup;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ringkasan Pembayaran',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Subtotal Buku
              _buildPriceRow(
                label: 'Subtotal Buku ($itemCount item)',
                value: _formatRupiah(subtotalValue),
              ),

              const SizedBox(height: 8),

              // Ongkos Kirim
              _buildPriceRow(
                label: 'Ongkos Kirim',
                value: isPickup ? 'Bebas Ongkir' : _formatRupiah(shippingFee),
                isHighlight: isPickup,
              ),

              const SizedBox(height: 8),

              // Biaya Layanan
              _buildPriceRow(
                label: 'Biaya Layanan',
                value: _formatRupiah(serviceFee),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.surfaceContainer,
                ),
              ),

              // Total Pembayaran Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Termasuk PPN jika berlaku',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatRupiah(totalPayment),
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Reassurance Trust Footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Kemasan ramah lingkungan & garansi buku original',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 13.5,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(
            color: isHighlight ? const Color(0xFF3F8F5F) : AppColors.onSurface,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
