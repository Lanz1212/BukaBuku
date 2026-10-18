import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/book_detail.dart';

/// Book cover display with subtle elevation and fallback typography aesthetic
class BookCoverSection extends StatelessWidget {
  final BookDetail book;

  const BookCoverSection({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 175,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.16),
                blurRadius: 26,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(-2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Network Cover Image
                Positioned.fill(
                  child: Image.network(
                    book.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackCover(),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _buildFallbackCover();
                    },
                  ),
                ),

                // Subtle book spine shine overlay on left edge
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// High fidelity stylized cover fallback matching Atomic Habits design
  Widget _buildFallbackCover() {
    return Container(
      color: const Color(0xFFFBF8F2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Bestseller Badge
          Column(
            children: [
              Text(
                'THE INTERNATIONAL',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFB06F38),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'BESTSELLER',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFB06F38),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 32,
                height: 1.5,
                color: const Color(0xFFB06F38),
              ),
            ],
          ),

          // Circle motif
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDCC8B3),
                width: 5,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF6B5341),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Title & Subtitle
          Column(
            children: [
              Text(
                'ATOMIC',
                style: AppTypography.titleMd.copyWith(
                  color: const Color(0xFF282522),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  fontSize: 14,
                  height: 1.1,
                ),
              ),
              Text(
                'HABITS',
                style: AppTypography.titleMd.copyWith(
                  color: const Color(0xFF282522),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  fontSize: 14,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Perubahan Kecil yang\nMemberikan Hasil Luar Biasa',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF6E6862),
                  fontSize: 7.5,
                  height: 1.2,
                ),
              ),
            ],
          ),

          // Author & Publisher
          Column(
            children: [
              Text(
                book.author,
                style: AppTypography.labelMd.copyWith(
                  color: const Color(0xFF282522),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                book.publisher.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF908A83),
                  fontSize: 6.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
