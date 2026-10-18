import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/book_detail.dart';

/// Specification cards (Penulis, Penerbit, Tahun, Kategori, ISBN, Format)
class BookSpecsGrid extends StatelessWidget {
  final BookDetail book;

  const BookSpecsGrid({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'SPESIFIKASI BUKU',
          style: AppTypography.titleMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // Row 1: Penulis & Penerbit
        Row(
          children: [
            Expanded(
              child: _buildSpecCard(
                label: 'Penulis',
                value: book.author,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSpecCard(
                label: 'Penerbit',
                value: book.publisher,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 2: Tahun Terbit & Kategori
        Row(
          children: [
            Expanded(
              child: _buildSpecCard(
                label: 'Tahun Terbit',
                value: book.publishYear,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSpecCard(
                label: 'Kategori',
                value: book.category,
                valueColor: AppColors.secondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 3: ISBN & Format Buku (Full-width card with 2 columns)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ISBN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor ISBN',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.outline,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.isbn,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Format
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Format Buku',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.outline,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.format,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildSpecCard({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.outline,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
