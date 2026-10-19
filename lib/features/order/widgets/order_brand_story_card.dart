import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OrderBrandStoryCard extends StatelessWidget {
  const OrderBrandStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.eco_outlined,
                size: 22,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Sentuhan Kasih Toko Buku Budi',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSecondaryFixed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
              children: const [
                TextSpan(
                  text:
                      'Setiap paket dibungkus dengan kertas daur ulang ramah lingkungan (plastic-free), lengkap dengan ',
                ),
                TextSpan(
                  text: 'pembatas buku kayu jati khas Budi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                TextSpan(
                  text:
                      ' serta wangi seduhan kopi literasi untuk menemani perjalanan membaca Anda.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildFeatureBadge(
                icon: Icons.bookmark_added_outlined,
                label: 'Gratis Pembatas Kayu',
              ),
              _buildFeatureBadge(
                icon: Icons.verified_user_outlined,
                label: 'Garansi Buku Asli',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.secondary,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
