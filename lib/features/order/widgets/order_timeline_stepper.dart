import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Vertical timeline stepper displaying the bookstore preparation stages:
/// 1. Pesanan Diterima (Finished)
/// 2. Pengepakan Buku & Pembatas Kayu (In progress)
/// 3. Siap Diambil / Dikirim (Upcoming based on delivery mode)
class OrderTimelineStepper extends StatelessWidget {
  final bool isDelivery;

  const OrderTimelineStepper({
    super.key,
    this.isDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    final step3Title = isDelivery ? '3. Siap Dikirim Kurir' : '3. Siap Diambil di Rak Toko';
    final step3Description = isDelivery
        ? 'Paket diserahkan ke kurir untuk perjalanan menuju lokasimu.'
        : 'Buku siap diambil langsung di meja kasir Toko Buku Budi Cikini.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Langkah Selanjutnya',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Update Otomatis',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stepper Items
          _buildTimelineItem(
            icon: Icons.check,
            iconColor: Colors.white,
            badgeColor: AppColors.success,
            title: '1. Pesanan Diterima',
            titleColor: AppColors.primary,
            description:
                'Data masuk dan kurator buku mulai memvalidasi inventaris.',
            showBottomLine: true,
          ),
          _buildTimelineItem(
            icon: Icons.inventory_2_outlined,
            iconColor: Colors.white,
            badgeColor: AppColors.secondary,
            title: '2. Pengepakan Buku & Pembatas Kayu',
            titleColor: AppColors.secondary,
            description:
                'Sedang diproses dengan sampul ramah lingkungan & cap eksklusif.',
            showBottomLine: true,
            isCurrentStep: true,
          ),
          _buildTimelineItem(
            icon: isDelivery
                ? Icons.local_shipping_outlined
                : Icons.storefront_outlined,
            iconColor: AppColors.onSurfaceVariant,
            badgeColor: AppColors.surfaceContainerHighest,
            title: step3Title,
            titleColor: AppColors.onSurfaceVariant,
            description: step3Description,
            showBottomLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required Color badgeColor,
    required String title,
    required Color titleColor,
    required String description,
    required bool showBottomLine,
    bool isCurrentStep = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Dot/Icon + Connecting Line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: isCurrentStep
                    ? [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
            ),
            if (showBottomLine)
              Container(
                width: 2,
                height: 38,
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Right Column: Texts
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLg.copyWith(
                    color: titleColor,
                    fontWeight: isCurrentStep ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
