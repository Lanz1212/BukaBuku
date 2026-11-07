import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/book_review.dart';

class ReviewCard extends StatelessWidget {
  final BookReview review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwner;

  const ReviewCard({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reviewer info + Stars + Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar or Initials
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: review.userAvatar != null && review.userAvatar!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          review.userAvatar!,
                          fit: BoxFit.cover,
                          width: 38,
                          height: 38,
                          errorBuilder: (context, error, stackTrace) =>
                              Text(
                            review.reviewerInitials,
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        review.reviewerInitials,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),

              const SizedBox(width: 10),

              // Name + Verified Badge + Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${review.timeAgo} • Pembeli Toko Buku Budi',
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
                  final isFilled = index < review.rating;
                  return Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 15,
                      color: isFilled
                          ? const Color(0xFFE59819)
                          : AppColors.outlineVariant,
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment Quote
          if (review.comment.isNotEmpty) ...[
            Text(
              '“${review.comment}”',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],

          if (isOwner) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 14),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

