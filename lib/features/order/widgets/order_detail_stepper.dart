import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_model.dart';

class OrderDetailStepper extends StatelessWidget {
  final List<OrderTimelineStepModel> steps;
  final String updatedTime;

  const OrderDetailStepper({
    super.key,
    required this.steps,
    this.updatedTime = 'Diperbarui 16:15',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Perjalanan Buku',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  updatedTime,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Stepper Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicator Column (Circle + Connector Line)
                    SizedBox(
                      width: 28,
                      child: Column(
                        children: [
                          _buildIndicator(step),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: step.isDone
                                    ? AppColors.secondary.withValues(alpha: 0.4)
                                    : AppColors.surfaceContainerHighest,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content Column
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  step.title,
                                  style: AppTypography.labelMd.copyWith(
                                    color: step.isActive
                                        ? AppColors.primary
                                        : step.isDone
                                            ? AppColors.onSurface
                                            : AppColors.onSurfaceVariant,
                                    fontWeight: step.isActive || step.isDone
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                if (step.time.isNotEmpty)
                                  Text(
                                    step.time,
                                    style: AppTypography.caption.copyWith(
                                      color: step.isActive
                                          ? AppColors.secondary
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: step.isActive
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              step.description,
                              style: AppTypography.caption.copyWith(
                                color: step.isActive
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(OrderTimelineStepModel step) {
    if (step.isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    if (step.isActive) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_stories_rounded,
          size: 14,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.outlineVariant,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
