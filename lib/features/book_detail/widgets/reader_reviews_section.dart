import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../review/models/book_review.dart';
import '../../review/widgets/review_card.dart';

/// Reader Reviews section displaying real reviews from database and "Lihat Semua" link
class ReaderReviewsSection extends StatelessWidget {
  final List<BookReview> reviews;
  final VoidCallback? onSeeAllPressed;
  final VoidCallback? onWriteReviewPressed;
  final bool canWriteReview;
  final bool hasReviewed;
  final String? currentUserId;

  const ReaderReviewsSection({
    super.key,
    required this.reviews,
    this.onSeeAllPressed,
    this.onWriteReviewPressed,
    this.canWriteReview = false,
    this.hasReviewed = false,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header + "Lihat Semua"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'ULASAN PEMBACA',
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
                if (reviews.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${reviews.length}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (reviews.isNotEmpty && onSeeAllPressed != null)
              GestureDetector(
                onTap: onSeeAllPressed,
                child: Text(
                  'Lihat Semua',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // If user purchased this book, show review button
        if (canWriteReview && onWriteReviewPressed != null) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.rate_review_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasReviewed ? 'Ulasan Anda Tercatat' : 'Anda Sudah Membeli Buku Ini',
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        hasReviewed
                            ? 'Ketuk tombol untuk memperbarui rating atau ulasan Anda.'
                            : 'Bagikan pengalaman membaca Anda untuk pembaca lain.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSecondaryContainer.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onWriteReviewPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.onSecondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(hasReviewed ? 'Edit Ulasan' : 'Beri Ulasan'),
                ),
              ],
            ),
          ),
        ],

        // Review List or Empty state
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 36,
                  color: AppColors.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada ulasan untuk buku ini',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Semua ulasan berasal dari pembeli nyata Toko Buku Budi.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...reviews.take(3).map(
                (review) => ReviewCard(
                  review: review,
                  isOwner: currentUserId != null && review.userId == currentUserId,
                  onEdit: onWriteReviewPressed,
                ),
              ),
      ],
    );
  }
}
