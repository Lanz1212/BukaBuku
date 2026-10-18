import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../search/models/book_search_item.dart';
import '../models/book_detail.dart';

/// Title, author, rating, price, and store stock pill section
class BookPriceHeader extends StatelessWidget {
  final BookDetail book;

  const BookPriceHeader({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Book Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.25,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Author
        Text(
          '${book.authorPrefix} ${book.author}',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        // Rating Stars + Count
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5),
                child: Icon(
                  Icons.star_rounded,
                  size: 19,
                  color: Color(0xFFE59819),
                ),
              );
            }),
            const SizedBox(width: 5),
            Text(
              book.rating.toString(),
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${book.reviewCountFormatted} ulasan pembaca)',
              style: AppTypography.caption.copyWith(
                color: AppColors.outline,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Price, Original Price, and Discount Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              book.price,
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              book.originalPrice,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.outline,
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                book.discountPercentage,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFD9534F),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Stock Status Pill
        _buildStockPill(),
      ],
    );
  }

  Widget _buildStockPill() {
    Color dotColor;
    String stockText;

    switch (book.stockStatus) {
      case StockStatus.inStock:
        dotColor = const Color(0xFF2E7D32);
        stockText = 'Stok Tersedia (Tersisa ${book.remainingStock} buku di ${book.storeLocation})';
        break;
      case StockStatus.limited:
        dotColor = const Color(0xFFD99A35);
        stockText = 'Stok Terbatas (Tersisa ${book.remainingStock} buku di ${book.storeLocation})';
        break;
      case StockStatus.outOfStock:
        dotColor = AppColors.outline;
        stockText = 'Stok Habis (Habis di ${book.storeLocation})';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              stockText,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
