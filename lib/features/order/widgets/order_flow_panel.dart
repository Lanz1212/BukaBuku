import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_simulation_flow.dart';
import 'order_cashier_qr_card.dart';

/// Dynamic panel rendering the active simulation flow details
/// (Antar Rumah, Ambil Online, or Bayar Kasir).
class OrderFlowPanel extends StatelessWidget {
  final OrderSimulationFlow flow;
  final String orderId;

  const OrderFlowPanel({
    super.key,
    required this.flow,
    this.orderId = '#ORD00125',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(flow),
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
      ),
    );
  }

  Widget _buildFlowContent() {
    switch (flow) {
      case OrderSimulationFlow.delivery:
        return _buildDeliveryFlow();
      case OrderSimulationFlow.pickupOnline:
        return _buildPickupOnlineFlow();
      case OrderSimulationFlow.pickupCash:
        return _buildPickupCashFlow();
    }
  }

  /// 1. Antar Rumah Flow
  Widget _buildDeliveryFlow() {
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
          'Lunas (QRIS)',
          statusColor: AppColors.success,
          statusIcon: Icons.check_circle,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Alamat Penerima',
          'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat',
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Estimasi Sampai',
          'Besok, 13 Mei 2024',
          valueColor: AppColors.primary,
          isBoldValue: true,
        ),
      ],
    );
  }

  /// 2. Ambil Online Flow
  Widget _buildPickupOnlineFlow() {
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
          'Lunas (Transfer)',
          statusColor: AppColors.success,
          statusIcon: Icons.check_circle,
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          'Lokasi Toko',
          'Toko Buku Budi Cikini\nJl. Cikini Raya No. 42 (Pojok Baca & Rak Sastra)',
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
                      const TextSpan(text: 'Tunjukkan ID '),
                      TextSpan(
                        text: orderId,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                        text:
                            ' ke staf kasir ketika status pesanan berubah menjadi "Siap Diambil".',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3. Bayar Kasir Flow (Default active in screenshot)
  Widget _buildPickupCashFlow() {
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
          'Toko Buku Budi Cikini (Jl. Cikini Raya No. 42)',
        ),
        const SizedBox(height: 12),

        // Exact Notice Box: "Siapkan Uang Pas Rp169.000"
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
                      'Siapkan Uang Pas Rp169.000',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSecondaryFixed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Buku sedang disiapkan kurator kami dalam 30 menit. Silakan serahkan tiket barcode di bawah ini ke meja kasir.',
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

        // Cashier QR Code Box
        const OrderCashierQrCard(
          qrCodeText: 'ORD-00125-CKN',
          cashierInstructions:
              'Tunjukkan QR Code ini kepada kasir saat mengambil pesanan',
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
