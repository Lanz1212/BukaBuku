import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Store Operational Hours & Schedule Card
class StoreHoursCard extends StatelessWidget {
  final String openTime;
  final String closeTime;
  final String operatingDays;
  final VoidCallback? onSelectOpenTime;
  final VoidCallback? onSelectCloseTime;

  const StoreHoursCard({
    super.key,
    this.openTime = '08:00 WIB',
    this.closeTime = '21:00 WIB',
    this.operatingDays = 'Buka Setiap Hari (Senin - Minggu)',
    this.onSelectOpenTime,
    this.onSelectCloseTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jam Operasional',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Aktif',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two-Column Opening & Closing Time
          Row(
            children: [
              // Jam Buka
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam Buka',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onSelectOpenTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                openTime,
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Jam Tutup
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam Tutup',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: onSelectCloseTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.nightlight_outlined,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                closeTime,
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Operating Days Badge Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  operatingDays,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
