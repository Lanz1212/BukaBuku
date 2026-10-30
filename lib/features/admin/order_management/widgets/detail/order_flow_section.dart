import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../models/admin_order_detail.dart';
import 'detail_section_card.dart';

class OrderFlowSection extends StatefulWidget {
  final AdminOrderDetail order;
  final VoidCallback onScanQr;
  final ValueChanged<AdminOrderStatus>? onStatusChanged;

  const OrderFlowSection({
    super.key,
    required this.order,
    required this.onScanQr,
    this.onStatusChanged,
  });

  @override
  State<OrderFlowSection> createState() => _OrderFlowSectionState();
}

class _OrderFlowSectionState extends State<OrderFlowSection> {
  late bool _isPickupMode;

  @override
  void initState() {
    super.initState();
    _isPickupMode = !widget.order.deliveryType.contains('Kurir');
  }

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Mode Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Alur Pengelolaan\nPesanan',
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontSize: 14.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Segmented Pills
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE8E3),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPickupMode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isPickupMode
                              ? const Color(0xFF5B4636)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Pickup\nAktif',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: _isPickupMode
                                ? Colors.white
                                : const Color(0xFF6B655F),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPickupMode = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !_isPickupMode
                              ? const Color(0xFF5B4636)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Alur\nDelivery',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: !_isPickupMode
                                ? Colors.white
                                : const Color(0xFF6B655F),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Instruction Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 20,
                    color: Color(0xFF9E7755),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPickupMode
                            ? 'Instruksi Pengambilan'
                            : 'Instruksi Pengantaran Kurir',
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _isPickupMode
                            ? 'Pesanan telah dikemas rapi di meja kasir. Mintalah pelanggan membuka halaman "Pesanan Saya" untuk memindai QR verifikasi serah-terima.'
                            : 'Pastikan paket buku telah tertutup rapat dan ditempeli nota pengiriman sebelum diserahkan kepada kurir toko.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.8,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Flow Step Chips
          Row(
            children: [
              // Step 1
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFECE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Color(0xFF7A736B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1. Buku Disiapkan',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF7A736B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Step 2
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDCB9B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Color(0xFF995E2B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPickupMode ? '2. Siap Diambil' : '2. Siap Dikirim',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF995E2B),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Card Action Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4636),
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.onScanQr,
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 18,
            ),
            label: Text(
              _isPickupMode
                  ? 'Pindai QR Pickup Customer'
                  : 'Konfirmasi Serah ke Kurir',
              style: AppTypography.labelLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
