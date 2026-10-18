import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Expandable Book Description section with toggle button
class BookDescription extends StatefulWidget {
  final String description;

  const BookDescription({
    super.key,
    required this.description,
  });

  @override
  State<BookDescription> createState() => _BookDescriptionState();
}

class _BookDescriptionState extends State<BookDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'DESKRIPSI BUKU',
          style: AppTypography.titleMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // Description Card
        Container(
          width: double.infinity,
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
              AnimatedCrossFade(
                firstChild: Text(
                  widget.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                    fontSize: 13.5,
                  ),
                ),
                secondChild: Text(
                  widget.description,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                    fontSize: 13.5,
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),

              const SizedBox(height: 10),

              // Toggle Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'Sembunyikan' : 'Baca Selengkapnya',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
