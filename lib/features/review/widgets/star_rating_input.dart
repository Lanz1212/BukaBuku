import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;

  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 36,
  });

  String _getRatingLabel(int value) {
    switch (value) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Kurang Memuaskan';
      case 3:
        return 'Cukup Bagus';
      case 4:
        return 'Bagus & Bermanfaat';
      case 5:
        return 'Luar Biasa / Sangat Puas!';
      default:
        return 'Pilih Rating Anda';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final isFilled = starValue <= rating;
            return GestureDetector(
              onTap: () => onRatingChanged(starValue),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: starSize,
                  color: isFilled
                      ? const Color(0xFFE59819)
                      : AppColors.outlineVariant,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _getRatingLabel(rating),
            key: ValueKey<int>(rating),
            style: AppTypography.titleMd.copyWith(
              color: rating > 0
                  ? const Color(0xFFC47B09)
                  : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

