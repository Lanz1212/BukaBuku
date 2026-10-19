import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_simulation_flow.dart';

/// Vertical timeline stepper displaying the bookstore preparation stages:
/// 1. Pesanan Diterima (Finished)
/// 2. Pengepakan Buku & Pembatas Kayu (In progress)
/// 3. Siap Diambil / Dikirim (Upcoming based on flow)
class OrderTimelineStepper extends StatelessWidget {
  final OrderSimulationFlow flow;

  const OrderTimelineStepper({
    super.key,
    required this.flow,
  });

  @override
  Widget build(BuildContext context) {
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
            icon: flow == OrderSimulationFlow.delivery
                ? Icons.local_shipping_outlined
                : Icons.storefront_outlined,
            iconColor: AppColors.onSurfaceVariant,
            badgeColor: AppColors.surfaceContainerHighest,
            title: flow.step3Title,
            titleColor: AppColors.onSurfaceVariant,
            description: flow.step3Description,
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Indicator Line & Dot
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 13,
                  color: iconColor,
                ),
              ),
              if (showBottomLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.surfaceContainerHighest,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Title & Description
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showBottomLine ? 16 : 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMd.copyWith(
                      color: titleColor,
                      fontWeight:
                          isCurrentStep ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
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
      ),
    );
  }
}
