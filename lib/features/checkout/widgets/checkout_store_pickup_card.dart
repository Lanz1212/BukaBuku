import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/checkout_order.dart';

/// Card showing physical store details for in-store pickup orders,
/// map preview, and pickup instructions.
class CheckoutStorePickupCard extends StatelessWidget {
  final StoreInfo storeInfo;
  final VoidCallback onOpenMap;

  const CheckoutStorePickupCard({
    super.key,
    required this.storeInfo,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Cash Pickup Banner Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                      fontSize: 12,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Pembayaran Cash ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      TextSpan(
                        text:
                            'tersedia saat mengambil pesanan di kasir Toko Cikini. Anda juga tetap dapat membayar instan via QRIS sekarang.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 2. Physical Store Details Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 12,
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
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            storeInfo.name,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      storeInfo.badge,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Address
              Text(
                storeInfo.address,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 10),

              // Hours & Phone row
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        storeInfo.operatingHours,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.call_outlined,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        storeInfo.phone,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Map Preview Box
              GestureDetector(
                onTap: onOpenMap,
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surfaceContainer,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            storeInfo.mapImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 32,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_outlined,
                                  size: 15,
                                  color: AppColors.primaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Buka di Google Maps',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
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

        const SizedBox(height: 10),

        // 3. Instruction Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instruksi Pengambilan:',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSecondaryContainer,
                          height: 1.35,
                          fontSize: 12.5,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Pesanan dapat diambil setelah status berubah menjadi ',
                          ),
                          TextSpan(
                            text: "'Siap Diambil'",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: '. Harap tunjukkan nomor ',
                          ),
                          TextSpan(
                            text: 'Order ID',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ' ke kasir saat pengambilan.',
                          ),
                        ],
                      ),
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
}
