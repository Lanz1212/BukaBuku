import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/checkout_order.dart';

/// Payment method selector card with 2 options: Midtrans & Bayar di Kasir.
class CheckoutPaymentSelector extends StatelessWidget {
  final PaymentMethodOption selectedPayment;
  final FulfillmentMode fulfillmentMode;
  final ValueChanged<PaymentMethodOption> onPaymentChanged;
  final VoidCallback? onOpenPaymentMethods;

  const CheckoutPaymentSelector({
    super.key,
    required this.selectedPayment,
    required this.fulfillmentMode,
    required this.onPaymentChanged,
    this.onOpenPaymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = fulfillmentMode == FulfillmentMode.pickup;
    final options = PaymentMethodOption.allOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Metode Pembayaran',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Aman & Terverifikasi',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // List of 2 Payment Methods
        ...options.map((option) {
          final isSelected = selectedPayment.id == option.id;
          final isCashOption = option.id == 'cash';
          final isDisabled = isCashOption && !isPickup;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: isDisabled
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Metode Bayar di Kasir hanya berlaku jika opsi "Ambil di Toko" dipilih.',
                          ),
                          backgroundColor: AppColors.primaryContainer,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  : () => onPaymentChanged(option),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? AppColors.surfaceContainerLowest.withValues(alpha: 0.6)
                      : (isSelected
                          ? AppColors.surfaceContainerLow
                          : AppColors.surfaceContainerLowest),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.outlineVariant.withValues(alpha: 0.35),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(
                        alpha: isSelected ? 0.08 : 0.02,
                      ),
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? AppColors.surfaceContainer
                            : (isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.surfaceContainer),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option.icon,
                        size: 22,
                        color: isDisabled
                            ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.primaryContainer),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Texts & Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  option.title,
                                  style: AppTypography.titleMd.copyWith(
                                    color: isDisabled
                                        ? AppColors.onSurfaceVariant
                                            .withValues(alpha: 0.5)
                                        : AppColors.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 14.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (option.badge != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDisabled
                                        ? AppColors.surfaceContainer
                                        : AppColors.secondaryContainer
                                            .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    isDisabled
                                        ? 'Khusus Ambil di Toko'
                                        : option.badge!,
                                    style: AppTypography.caption.copyWith(
                                      color: isDisabled
                                          ? AppColors.onSurfaceVariant
                                              .withValues(alpha: 0.6)
                                          : AppColors.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isDisabled
                                ? 'Ubah mode pengiriman ke "Ambil di Toko" untuk mengaktifkan metode ini.'
                                : option.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: isDisabled
                                  ? AppColors.onSurfaceVariant
                                      .withValues(alpha: 0.45)
                                  : AppColors.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Selection Indicator
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isDisabled
                          ? AppColors.outlineVariant.withValues(alpha: 0.3)
                          : (isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
