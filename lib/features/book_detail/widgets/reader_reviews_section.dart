import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/book_detail.dart';

/// Reader Reviews section displaying reviews and "Lihat Semua" link
class ReaderReviewsSection extends StatelessWidget {
  final List<BookReview> reviews;
  final VoidCallback? onSeeAllPressed;

  const ReaderReviewsSection({
    super.key,
    required this.reviews,
    this.onSeeAllPressed,
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
            Text(
              'ULASAN PEMBACA',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
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

        // Review Cards
        ...reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Initials
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerInitials,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Name + Verified Badge + Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.reviewerName,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4F2E4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Terverifikasi',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF1B6B3F),
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${review.timeAgo} • ${review.purchaseLocation}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.outline,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Star Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: Color(0xFFE59819),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment Quote
          Text(
            '“${review.comment}”',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
