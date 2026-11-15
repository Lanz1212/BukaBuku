import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../models/admin_order_detail.dart';
import 'detail_section_card.dart';

class CustomerInfoSection extends StatelessWidget {
  final AdminOrderDetail order;

  const CustomerInfoSection({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = order.deliveryType.toLowerCase().contains('kurir') ||
        order.deliveryType.toLowerCase().contains('delivery');

    final pickupPoint = order.pickupPoint?.trim().isNotEmpty == true
        ? order.pickupPoint!
        : 'Gerai Utama Buka Buku, Meja Kasir 1';

    final deliveryAddress = order.address?.trim().isNotEmpty == true
        ? order.address!
        : (order.accountAddress?.trim().isNotEmpty == true
            ? order.accountAddress!
            : 'Alamat pengiriman pembeli belum dicantumkan');

    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Verification Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi Pelanggan',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (order.isVerifiedUser)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Akun Terverifikasi',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Name & Phone (Tanpa icon telepon)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.customerName,
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.customerPhone,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Location Sub-Container (Sesuai jenis pengiriman: Ambil di Toko vs Delivery)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: isDelivery
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.home_outlined,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat Pengiriman (Kurir Toko)',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              deliveryAddress,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF946A42),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Titik Pengambilan Toko',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF946A42),
                                fontWeight: FontWeight.w700,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pickupPoint,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurface,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
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
