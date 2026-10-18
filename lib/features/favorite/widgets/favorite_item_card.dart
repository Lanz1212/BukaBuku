import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../search/models/book_search_item.dart';
import '../models/favorite_item.dart';

/// A single favorite book card matching the Stitch "Buku Favorit" screen.
/// Displays cover image with badge, title, author, stock status,
/// price, and action buttons (add to cart / remind).
class FavoriteItemCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onRemoveFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback? onRemind;
  final VoidCallback? onTap;

  const FavoriteItemCard({
    super.key,
    required this.item,
    required this.onRemoveFavorite,
    required this.onAddToCart,
    this.onRemind,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = item.stockStatus == StockStatus.outOfStock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover Image with Badge
          _buildCoverImage(isOutOfStock),
          const SizedBox(width: 16),

          // Book Details
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with heart button
                _buildTitleRow(),
                const SizedBox(height: 2),

                // Author
                Text(
                  item.author,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Stock status indicator
                _buildStockIndicator(),
                const SizedBox(height: 12),

                // Price and action button row
                _buildPriceAndActionRow(isOutOfStock),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(bool isOutOfStock) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        height: 144,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
          children: [
            // Cover image
            Container(
              color: AppColors.surfaceContainer,
              child: Image.network(
                item.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerLow,
                    child: const Center(
                      child: Icon(
                        Icons.menu_book,
                        size: 36,
                        color: AppColors.outline,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Grayscale overlay for out-of-stock items
            if (isOutOfStock) ...[
              Container(
                color: AppColors.onSurface.withValues(alpha: 0.2),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Habis',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Badge (Bestseller, Edisi Baru, Terbatas)
            if (item.badgeType != FavoriteBadgeType.none && !isOutOfStock)
              Positioned(
                top: 6,
                left: 6,
                child: _buildBadge(),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBadge() {
    String label;
    Color bgColor;
    Color textColor;

    switch (item.badgeType) {
      case FavoriteBadgeType.bestseller:
        label = 'Bestseller';
        bgColor = Colors.white.withValues(alpha: 0.9);
        textColor = AppColors.secondary;
      case FavoriteBadgeType.edisiBaru:
        label = 'Edisi Baru';
        bgColor = Colors.white.withValues(alpha: 0.9);
        textColor = AppColors.secondary;
      case FavoriteBadgeType.terbatas:
        label = 'Terbatas';
        bgColor = AppColors.secondaryFixed;
        textColor = AppColors.onSecondaryContainer;
      case FavoriteBadgeType.none:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              item.title,
              style: AppTypography.titleMd.copyWith(
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Favorite heart button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9999),
            onTap: onRemoveFavorite,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.favorite,
                size: 22,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockIndicator() {
    Color dotColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.w500;

    switch (item.stockStatus) {
      case StockStatus.inStock:
        dotColor = const Color(0xFF3F8F5F); // Success green from DESIGN.md
        textColor = const Color(0xFF2D6B45);
      case StockStatus.limited:
        dotColor = const Color(0xFFD99A35); // Warning amber from DESIGN.md
        textColor = const Color(0xFF9A6F1D);
        fontWeight = FontWeight.w600;
      case StockStatus.outOfStock:
        dotColor = AppColors.error;
        textColor = AppColors.error;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.stockLabel,
          style: AppTypography.caption.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndActionRow(bool isOutOfStock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harga',
              style: AppTypography.caption.copyWith(
                color: AppColors.outline,
              ),
            ),
            Text(
              item.price,
              style: AppTypography.titleMd.copyWith(
                color: isOutOfStock
                    ? AppColors.onSurfaceVariant
                    : AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        // Action button
        isOutOfStock
            ? _buildRemindButton()
            : _buildAddToCartButton(),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_shopping_cart,
                size: 18,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                '+ Keranjang',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemindButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRemind,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none,
                size: 17,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Ingatkan',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
