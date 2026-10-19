import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_item_model.dart';

class OrderDetailBookItem extends StatelessWidget {
  final OrderItemModel item;

  const OrderDetailBookItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isSpecialEdition = item.tag != null &&
        item.tag!.toLowerCase().contains('khusus');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Cover
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 64,
            height: 90,
            color: AppColors.surfaceContainerHigh,
            child: Image.network(
              item.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceContainerHighest,
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 28,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Book details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.author,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (item.tag != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSpecialEdition
                        ? AppColors.secondaryFixed
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.tag!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSpecialEdition ? FontWeight.w600 : FontWeight.w500,
                      color: isSpecialEdition
                          ? AppColors.onSecondaryFixedVariant
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity}x ${item.pricePerUnit}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    item.subtotal,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
