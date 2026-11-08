import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_model.dart';
import 'order_cashier_qr_card.dart';

/// Dynamic panel rendering the active real order fulfillment details
/// (Antar Rumah, Ambil Online, or Bayar Kasir).
class OrderFlowPanel extends StatelessWidget {
  final OrderModel order;

  const OrderFlowPanel({
    super.key,
    required this.order,
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
      child: _buildFlowContent(),
    );
  }

  Widget _buildFlowContent() {
    if (order.deliveryType == DeliveryType.delivery) {
      return _buildDeliveryFlow();
    } else if (order.isPaid) {
      return _buildPickupOnlineFlow();
    } else {
      return _buildPickupCashFlow();
    }
  }

  /// 1. Antar Rumah Flow
  Widget _buildDeliveryFlow() {
    final address = order.customerAddress?.isNotEmpty == true
        ? order.customerAddress!
        : 'Alamat pengantaran pembaca';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Informasi Pengantaran',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoBox('Metode', 'Antar ke Rumah (Kurir Toko)'),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Status Pembayaran',
          order.isPaid ? 'Lunas (${order.paymentMethod})' : 'Menunggu Pembayaran',
          statusColor: order.isPaid ? AppColors.success : AppColors.secondary,
          statusIcon: order.isPaid ? Icons.check_circle : Icons.pending_outlined,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Penerima',
          '${order.customerName}${order.customerPhone != null && order.customerPhone!.isNotEmpty ? " • ${order.customerPhone}" : ""}',
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Alamat Tujuan',
          address,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Estimasi Sampai',
          'Besok (Kurir Toko Buka Buku)',
          valueColor: AppColors.primary,
          isBoldValue: true,
        ),
      ],
    );
  }

  /// 2. Ambil di Toko - Pembayaran Online Sudah Lunas
  Widget _buildPickupOnlineFlow() {
    final location = order.pickupLocation?.isNotEmpty == true
        ? order.pickupLocation!
        : (order.branchName?.isNotEmpty == true
            ? order.branchName!
            : 'Gerai Utama Buka Buku Cikini');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.storefront_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pengambilan di Toko',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoBox('Metode', 'Ambil di Toko (Bebas Ongkir)'),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Status Bayar',
          'Lunas (${order.paymentMethod})',
          statusColor: AppColors.success,
          statusIcon: Icons.check_circle,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Lokasi Toko',
          location,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      height: 1.35,
                    ),
                    children: [
                      const TextSpan(text: 'Tunjukkan QR Code atau ID '),
                      TextSpan(
                        text: order.id,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                        text: ' ke meja kasir untuk pengambilan buku Anda.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OrderCashierQrCard(
          qrCodeText: order.qrCode.isNotEmpty ? order.qrCode : order.id,
          cashierInstructions:
              'Tunjukkan QR Code ini kepada kasir saat mengambil buku di toko',
        ),
      ],
    );
  }

  /// 3. Ambil di Toko - Bayar di Kasir
  Widget _buildPickupCashFlow() {
    final location = order.pickupLocation?.isNotEmpty == true
        ? order.pickupLocation!
        : 'Gerai Utama Buka Buku (Meja Kasir 1)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.point_of_sale_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pengambilan & Pembayaran Kasir',
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoBox('Metode Pengambilan', 'Ambil di Toko (Bebas Ongkir)'),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Status Pembayaran',
          'Bayar di Kasir',
          statusColor: AppColors.secondary,
          statusIcon: Icons.pending_outlined,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Lokasi Kasir',
          location,
        ),
        const SizedBox(height: 12),

        // Notice Box with real amount
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 20,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siapkan Uang Pas ${order.totalAmount}',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSecondaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Buku dapat diambil di toko. Silakan tunjukkan QR Code di bawah ini kepada kasir.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSecondaryFixed,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Cashier QR Code Box with actual orderId/qrCode
        OrderCashierQrCard(
          qrCodeText: order.qrCode.isNotEmpty ? order.qrCode : order.id,
          cashierInstructions:
              'Tunjukkan QR Code ini kepada kasir saat mengambil pesanan & membayar',
        ),
      ],
    );
  }

  Widget _buildInfoBox(
    String label,
    String value, {
    Color? valueColor,
    Color? statusColor,
    IconData? statusIcon,
    bool isBoldValue = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (statusIcon != null) ...[
                  Icon(
                    statusIcon,
                    size: 15,
                    color: statusColor ?? AppColors.onSurface,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: AppTypography.labelMd.copyWith(
                      color: statusColor ??
                          valueColor ??
                          AppColors.onSurface,
                      fontWeight: isBoldValue || statusColor != null
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.right,
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
