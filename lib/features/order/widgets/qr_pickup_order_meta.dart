import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QrPickupOrderMeta extends StatelessWidget {
  final String itemCountText;
  final String bookTitlesText;
  final String totalAmount;
  final String paymentStatus;
  final String pickupLocation;
  final String pickupSchedule;

  const QrPickupOrderMeta({
    super.key,
    this.itemCountText = '2 Buku Fisik',
    this.bookTitlesText = 'Atomic Habits • Filosofi Teras',
    this.totalAmount = 'Rp181.000',
    this.paymentStatus = 'Lunas via QRIS',
    this.pickupLocation = 'Meja Kasir 1, Toko Buku Budi Cikini',
    this.pickupSchedule = 'Buka Hari Ini: 08.00 - 21.00 WIB',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ticket Perforation Notch Illusion
        Container(
          height: 24,
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          child: Row(
            children: [
              // Left cutout notch
              Container(
                width: 12,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                ),
              ),

              // Dashed line between notches
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 5.0;
                    const dashSpace = 4.0;
                    final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dashCount, (_) {
                        return Container(
                          width: dashWidth,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              // Right cutout notch
              Container(
                width: 12,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Order metadata details
        Container(
          width: double.infinity,
          color: AppColors.surfaceContainerLowest,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Items count vs Total amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Item',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          itemCountText,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bookTitlesText,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Tagihan',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalAmount,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 13,
                            color: Color(0xFF2D6A4F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            paymentStatus,
                            style: AppTypography.caption.copyWith(
                              color: const Color(0xFF2D6A4F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),

              // Location & Hours Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.countertops_outlined,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi & Jam Pengambilan',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pickupLocation,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pickupSchedule,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
