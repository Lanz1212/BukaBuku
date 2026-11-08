import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../models/admin_order_detail.dart';
import 'detail_section_card.dart';

class OrderHeaderCard extends StatelessWidget {
  final AdminOrderDetail order;

  const OrderHeaderCard({
    super.key,
    required this.order,
  });

  String _getStatusDescription() {
    switch (order.status) {
      case AdminOrderStatus.siapDiambil:
        return 'Customer dapat melihat barcode/QR Pickup di aplikasi mereka untuk penyerahan buku.';
      case AdminOrderStatus.baru:
        return 'Pesanan baru masuk dari customer. Segera periksa dan siapkan buku fisik dari rak.';
      case AdminOrderStatus.diproses:
        return 'Buku sedang disiapkan dan dicek oleh staf kasir di meja persiapan.';
      case AdminOrderStatus.siapDikirim:
        return 'Paket buku telah selesai dikemas rapi dan siap diserahkan kepada kurir toko.';
      case AdminOrderStatus.dalamPengiriman:
        return 'Pesanan sedang diantar oleh kurir toko menuju alamat pengantaran customer.';
      case AdminOrderStatus.selesai:
        return 'Pesanan telah selesai dan buku telah diserahkan dengan verifikasi QR.';
      case AdminOrderStatus.dibatalkan:
        return 'Pesanan ini telah dibatalkan oleh customer atau pihak toko.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = order.orderDate ?? '12 Mei 2024, ${order.orderTime}';

    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order ID & Delivery Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: order.orderId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ID #${order.orderId} disalin ke papan klip'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: AppColors.outline.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.deliveryType.contains('Pickup') ||
                              order.deliveryType.contains('Ambil')
                          ? Icons.storefront_outlined
                          : Icons.local_shipping_outlined,
                      size: 13,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      order.deliveryType.contains('Ambil')
                          ? 'Ambil di Toko'
                          : order.deliveryType,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date & Payment Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateText,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECDA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.isPaid ? 'Lunas • QRIS' : 'Belum Lunas',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFFB5702F),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status Highlight Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF0DEC9),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5DFC9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_outlined,
                    color: Color(0xFFB06F34),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Status: ${order.statusLabel}',
                            style: AppTypography.titleMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9822B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _getStatusDescription(),
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.onSurfaceVariant,
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
