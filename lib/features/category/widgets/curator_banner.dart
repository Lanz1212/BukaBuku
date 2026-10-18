import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Curator Consultation Service Banner
class CuratorBanner extends StatelessWidget {
  final VoidCallback onConsultPressed;

  const CuratorBanner({
    super.key,
    required this.onConsultPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Decorative Circle
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixed.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag: Icon + LAYANAN KURATOR BUKU
                  Row(
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        size: 18,
                        color: AppColors.primaryFixed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LAYANAN KURATOR BUKU',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Headline
                  Text(
                    'Butuh Rekomendasi Khusus?',
                    style: AppTypography.headlineSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    'Konsultasikan langsung dengan kurator buku kami di toko untuk menemukan bacaan yang paling pas untuk Anda.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onPrimaryContainer,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Row: Button + Response time microcopy
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onConsultPressed,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mulai Diskusi',
                                  style: AppTypography.labelLg.copyWith(
                                    color: AppColors.primaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: AppColors.primaryContainer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Respons < 5 menit',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryFixedDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
