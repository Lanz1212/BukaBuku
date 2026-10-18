import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/book_search_item.dart';

/// 2-Column Book Grid Card in Search Results
class BookSearchCard extends StatefulWidget {
  final BookSearchItem book;
  final VoidCallback? onAddToCart;
  final VoidCallback? onNotifyMe;
  final VoidCallback? onTap;

  const BookSearchCard({
    super.key,
    required this.book,
    this.onAddToCart,
    this.onNotifyMe,
    this.onTap,
  });

  @override
  State<BookSearchCard> createState() => _BookSearchCardState();
}

class _BookSearchCardState extends State<BookSearchCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final bool isOutOfStock = book.stockStatus == StockStatus.outOfStock;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (highlighted) {
            setState(() {
              _isPressed = highlighted;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.45),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover taking remaining flexible height without overflowing
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: AppColors.surfaceContainerLow,
                            child: Image.network(
                              book.coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surfaceContainer,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.menu_book_rounded,
                                    size: 36,
                                    color: AppColors.outline,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.surfaceContainerLow,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Shelf Location Overlay badge if physical shelf is known
                        if (book.shelfLocation != null)
                          Positioned(
                            bottom: 6,
                            left: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.onSurface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 11,
                                    color: AppColors.secondaryFixed,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      book.shelfLocation!,
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Availability Tag
                _buildAvailabilityTag(book),

                const SizedBox(height: 4),

                // Book Title
                Text(
                  book.title,
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Author
                Text(
                  book.author,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Rating Bar
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: isOutOfStock
                          ? AppColors.outlineVariant
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      book.rating.toString(),
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(${book.reviewCount})',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Price and Action Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        book.price,
                        style: AppTypography.headlineSm.copyWith(
                          color: isOutOfStock
                              ? AppColors.onSurfaceVariant
                              : AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isOutOfStock ? widget.onNotifyMe : widget.onAddToCart,
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isOutOfStock
                                ? Icons.notifications_none_rounded
                                : Icons.add_shopping_cart_rounded,
                            size: 17,
                            color: isOutOfStock
                                ? AppColors.outline
                                : AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityTag(BookSearchItem book) {
    Color dotColor;
    Color textColor;

    switch (book.stockStatus) {
      case StockStatus.inStock:
        dotColor = const Color(0xFF3F8F5F);
        textColor = const Color(0xFF2E6930);
        break;
      case StockStatus.limited:
        dotColor = AppColors.secondary;
        textColor = AppColors.secondary;
        break;
      case StockStatus.outOfStock:
        dotColor = AppColors.outline;
        textColor = AppColors.outline;
        break;
    }

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          book.stockLabel,
          style: AppTypography.caption.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
