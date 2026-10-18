import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../search/models/book_search_item.dart';

/// Interactive developer/preview banner to toggle stock status
class StockSimulatorBanner extends StatelessWidget {
  final StockStatus currentStatus;
  final ValueChanged<StockStatus> onStatusChanged;

  const StockSimulatorBanner({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final nextStatus = currentStatus == StockStatus.inStock
        ? StockStatus.outOfStock
        : (currentStatus == StockStatus.outOfStock ? StockStatus.limited : StockStatus.inStock);

    String nextButtonLabel;
    switch (nextStatus) {
      case StockStatus.inStock:
        nextButtonLabel = 'Ubah ke: Stok Tersedia';
        break;
      case StockStatus.limited:
        nextButtonLabel = 'Ubah ke: Sisa Sedikit';
        break;
      case StockStatus.outOfStock:
        nextButtonLabel = 'Ubah ke: Stok Habis';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Simulasi Status Stok:',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onStatusChanged(nextStatus),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.8),
                  ),
                ),
                child: Text(
                  nextButtonLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
