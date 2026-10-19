import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/checkout_order.dart';

/// Payment method selector card with expandable alternative options.
class CheckoutPaymentSelector extends StatefulWidget {
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
  State<CheckoutPaymentSelector> createState() => _CheckoutPaymentSelectorState();
}

class _CheckoutPaymentSelectorState extends State<CheckoutPaymentSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final availableOptions = PaymentMethodOption.allOptions.where((option) {
      if (option.id == 'cash' &&
          widget.fulfillmentMode != FulfillmentMode.pickup) {
        return false;
      }
      return true;
    }).toList();

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
            const SizedBox(width: 8),
            if (widget.onOpenPaymentMethods != null)
              GestureDetector(
                onTap: widget.onOpenPaymentMethods,
                child: Text(
                  'Lihat Semua',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              Text(
                'Aman & Terverifikasi',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // Selected Payment Container (Expandable)
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
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Main Selected Tile
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.selectedPayment.icon,
                        size: 22,
                        color: AppColors.primaryContainer,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.selectedPayment.title,
                                style: AppTypography.titleMd.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (widget.selectedPayment.badge != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    widget.selectedPayment.badge!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.selectedPayment.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Trailing Arrow
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.chevron_right_rounded,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),

              // Expanded Options List
              if (_isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.surfaceContainer,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih metode pembayaran:',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...availableOptions.map((option) {
                  final isCurrent = option.id == widget.selectedPayment.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        widget.onPaymentChanged(option);
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.surfaceContainerLow
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  option.icon,
                                  size: 19,
                                  color: isCurrent
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  option.title,
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isCurrent
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: isCurrent
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
