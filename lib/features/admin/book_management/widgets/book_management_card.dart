import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_book_item.dart';

class BookManagementCard extends StatelessWidget {
  final AdminBookItem book;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BookManagementCard({
    super.key,
    required this.book,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = book.status == AdminBookStatus.outOfStock;
    final bool isMenipis = book.status == AdminBookStatus.menipis;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: book.isActive
            ? AppColors.surfaceContainerLowest
            : AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover with Shelf Location Badge
          _buildCover(isOutOfStock),
          const SizedBox(width: 12),

          // Right Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top: Title + Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        book.title,
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(isMenipis, isOutOfStock),
                  ],
                ),
                const SizedBox(height: 2),

                // Author
                Text(
                  book.author,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),

                // ISBN
                Text(
                  'ISBN: ${book.isbn}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.outline,
                    fontSize: 10.5,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Bottom: Price & Stock + Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price & Stock
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga & Stok',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.outline,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Rp${_formatNumber(book.price)}',
                              style: AppTypography.titleMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isOutOfStock
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.primary,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${book.stock} eks',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? AppColors.error
                                    : (isMenipis
                                        ? AppColors.secondary
                                        : AppColors.onSurfaceVariant),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Actions: Active toggle, Edit, Delete
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Active/Inactive toggle button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onToggleStatus,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: book.isActive
                                    ? AppColors.surfaceContainer
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: book.isActive
                                          ? AppColors.primaryContainer
                                          : AppColors.outline,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    book.isActive ? 'Aktif' : 'Nonaktif',
                                    style: AppTypography.caption.copyWith(
                                      color: book.isActive
                                          ? AppColors.primary
                                          : AppColors.outline,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Edit Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onEdit,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Delete Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onDelete,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(bool isOutOfStock) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 78,
            height: 108,
            child: ColorFiltered(
              colorFilter: isOutOfStock
                  ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.network(
                book.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(
                        Icons.book_rounded,
                        color: AppColors.outline,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Shelf Location Tag (e.g. G-04)
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: AppColors.onSurface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              book.rackLocation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // Habis banner overlay if out of stock
        if (isOutOfStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HABIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isMenipis, bool isOutOfStock) {
    Color bgColor;
    Color textColor;
    Color dotColor;
    String label;

    if (isOutOfStock) {
      bgColor = AppColors.errorContainer;
      textColor = AppColors.onErrorContainer;
      dotColor = AppColors.error;
      label = 'Stok 0';
    } else if (isMenipis) {
      bgColor = AppColors.secondaryFixed;
      textColor = AppColors.onSecondaryFixed;
      dotColor = AppColors.secondary;
      label = 'Menipis';
    } else {
      bgColor = AppColors.surfaceContainerHigh;
      textColor = AppColors.onSurface;
      dotColor = AppColors.primaryContainer;
      label = 'Tersedia';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
