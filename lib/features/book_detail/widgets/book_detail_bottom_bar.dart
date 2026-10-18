import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../search/models/book_search_item.dart';

/// Sticky bottom action bar with quantity stepper, add to cart, and buy now CTA
class BookDetailBottomBar extends StatelessWidget {
  final int quantity;
  final int unitPrice;
  final StockStatus stockStatus;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onNotifyMe;

  const BookDetailBottomBar({
    super.key,
    required this.quantity,
    required this.unitPrice,
    required this.stockStatus,
    required this.onQuantityChanged,
    this.onAddToCart,
    this.onBuyNow,
    this.onNotifyMe,
  });

  String _formatPrice(int amount) {
    // Basic Indonesian Rupiah formatting: Rp85.000
    final buffer = StringBuffer();
    final str = amount.toString();
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
    final isOutOfStock = stockStatus == StockStatus.outOfStock;
    final totalPriceStr = _formatPrice(unitPrice * quantity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Quantity Stepper + Tambah ke Keranjang
              Row(
                children: [
                  // Quantity Stepper
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minus Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (quantity > 1 && !isOutOfStock)
                                ? () => onQuantityChanged(quantity - 1)
                                : null,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            child: SizedBox(
                              width: 38,
                              height: 48,
                              child: Icon(
                                Icons.remove,
                                size: 18,
                                color: (quantity > 1 && !isOutOfStock)
                                    ? AppColors.onSurface
                                    : AppColors.outlineVariant,
                              ),
                            ),
                          ),
                        ),

                        // Quantity Value
                        SizedBox(
                          width: 32,
                          child: Text(
                            quantity.toString(),
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        // Plus Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: !isOutOfStock ? () => onQuantityChanged(quantity + 1) : null,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                            child: SizedBox(
                              width: 38,
                              height: 48,
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: !isOutOfStock ? AppColors.onSurface : AppColors.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Tambah ke Keranjang Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: isOutOfStock ? null : onAddToCart,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isOutOfStock
                                ? AppColors.outlineVariant
                                : AppColors.secondary,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: isOutOfStock ? AppColors.outline : AppColors.secondary,
                        ),
                        label: Text(
                          'Tambah ke Keranjang',
                          style: AppTypography.labelMd.copyWith(
                            color: isOutOfStock ? AppColors.outline : AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Row 2: Beli Sekarang or Beritahu Saya CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: isOutOfStock
                    ? ElevatedButton.icon(
                        onPressed: onNotifyMe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.onSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.notifications_none_rounded, size: 20),
                        label: Text(
                          'Beri Tahu Saya Saat Tersedia',
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onBuyNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 2,
                          shadowColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Beli Sekarang — $totalPriceStr',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
