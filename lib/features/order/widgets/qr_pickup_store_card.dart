import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QrPickupStoreCard extends StatelessWidget {
  final String storeName;
  final String deskName;
  final String orderId;
  final String customerName;

  const QrPickupStoreCard({
    super.key,
    this.storeName = 'Toko Buku Budi Cikini',
    this.deskName = 'Meja Kasir Pengambilan',
    this.orderId = '#ORD00125',
    this.customerName = 'Budi Santoso',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Decorative warm accent top stripe
        Container(
          height: 6,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
                AppColors.primaryContainer,
              ],
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                storeName,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deskName,
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ready status badge (soft green)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF7EE),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D6A4F),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Siap Diambil',
                          style: AppTypography.labelMd.copyWith(
                            color: const Color(0xFF2D6A4F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'REF ID',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        orderId,
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    customerName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
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
