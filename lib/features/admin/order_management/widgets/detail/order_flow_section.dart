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
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    _isPickupMode
                        ? Icons.qr_code_scanner_rounded
                        : Icons.two_wheeler_rounded,
                    size: 20,
                    color: const Color(0xFF9E7755),
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
                            : 'Instruksi Pengantaran Kurir Toko',
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _getInstructionText(),
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
          _buildStepChips(),
          const SizedBox(height: 12),

          // Card Action Button
          _buildActionButton(),
        ],
      ),
    );
  }

  String _getInstructionText() {
    if (_isPickupMode) {
      return 'Pesanan telah dikemas rapi di meja kasir. Mintalah pelanggan membuka halaman "Pesanan Saya" untuk memindai QR verifikasi serah-terima.';
    }

    switch (widget.order.status) {
      case AdminOrderStatus.baru:
        return 'Pesanan baru masuk. Ambil buku dari rak dan klik tombol di bawah untuk mulai menyiapkan.';
      case AdminOrderStatus.diproses:
        return 'Buku sedang disiapkan. Bungkus rapi dengan nota pengiriman sebelum menandai siap kirim.';
      case AdminOrderStatus.siapDiambil:
        return 'Pesanan telah siap di kasir untuk diambil oleh customer.';
      case AdminOrderStatus.siapDikirim:
        return 'Paket buku sudah siap di meja persiapan. Serahkan ke kurir toko yang akan mengantar.';
      case AdminOrderStatus.dalamPengiriman:
        return 'Kurir toko sedang dalam perjalanan ke alamat pembeli. Pesanan akan otomatis selesai saat pembeli menekan "Pesanan Sampai".';
      case AdminOrderStatus.selesai:
        return 'Pesanan telah selesai! Buku telah sampai dan diterima dengan aman oleh pembaca.';
      case AdminOrderStatus.dibatalkan:
        return 'Pesanan telah dibatalkan.';
    }
  }

  Widget _buildStepChips() {
    if (_isPickupMode) {
      final isStep1Done = widget.order.status != AdminOrderStatus.baru;
      final isStep2Done = widget.order.status == AdminOrderStatus.siapDiambil ||
          widget.order.status == AdminOrderStatus.selesai;

      return Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isStep1Done
                    ? const Color(0xFFEFECE6)
                    : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isStep1Done ? Icons.check_rounded : Icons.pending_outlined,
                    size: 13,
                    color: const Color(0xFF7A736B),
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
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isStep2Done
                    ? const Color(0xFFFDCB9B)
                    : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isStep2Done ? Icons.check_rounded : Icons.storefront_rounded,
                    size: 13,
                    color: const Color(0xFF995E2B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '2. Siap Diambil',
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
      );
    }

    // Delivery Steps (1. Disiapkan -> 2. Siap Dikirim -> 3. Kurir Jalan)
    final isPrepDone = widget.order.status != AdminOrderStatus.baru;
    final isReadyDone = widget.order.status == AdminOrderStatus.siapDikirim ||
        widget.order.status == AdminOrderStatus.dalamPengiriman ||
        widget.order.status == AdminOrderStatus.selesai;
    final isShippingDone = widget.order.status == AdminOrderStatus.dalamPengiriman ||
        widget.order.status == AdminOrderStatus.selesai;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isPrepDone ? const Color(0xFFEFECE6) : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPrepDone ? Icons.check_rounded : Icons.inventory_2_outlined,
                  size: 12,
                  color: const Color(0xFF7A736B),
                ),
                const SizedBox(width: 3),
                Text(
                  '1. Kemas',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF7A736B),
                    fontWeight: FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isReadyDone
                  ? const Color(0xFFE8DAEF)
                  : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isReadyDone ? Icons.check_rounded : Icons.inventory_rounded,
                  size: 12,
                  color: const Color(0xFF7D3C98),
                ),
                const SizedBox(width: 3),
                Text(
                  '2. Siap Kirim',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF7D3C98),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isShippingDone
                  ? const Color(0xFFFDCB9B)
                  : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isShippingDone ? Icons.check_rounded : Icons.two_wheeler_rounded,
                  size: 12,
                  color: const Color(0xFF995E2B),
                ),
                const SizedBox(width: 3),
                Text(
                  '3. Kurir Jalan',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF995E2B),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_isPickupMode) {
      return ElevatedButton.icon(
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
          'Pindai QR Pickup Customer',
          style: AppTypography.labelLg.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      );
    }

    // Delivery Mode Action Button
    switch (widget.order.status) {
      case AdminOrderStatus.baru:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () =>
              widget.onStatusChanged?.call(AdminOrderStatus.diproses),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: Text(
            'Mulai Siapkan Buku',
            style: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        );

      case AdminOrderStatus.diproses:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E44AD),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () =>
              widget.onStatusChanged?.call(AdminOrderStatus.siapDikirim),
          icon: const Icon(Icons.inventory_2_outlined, size: 18),
          label: Text(
            'Tandai Paket Siap Dikirim',
            style: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        );

      case AdminOrderStatus.siapDiambil:
        return const SizedBox.shrink();

      case AdminOrderStatus.siapDikirim:
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () =>
              widget.onStatusChanged?.call(AdminOrderStatus.dalamPengiriman),
          icon: const Icon(Icons.two_wheeler_rounded, size: 18),
          label: Text(
            'Serahkan ke Kurir Toko',
            style: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        );

      case AdminOrderStatus.dalamPengiriman:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.two_wheeler_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Kurir Sedang Mengantar ke Alamat',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );

      case AdminOrderStatus.selesai:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pesanan Telah Diterima Pembeli (Selesai)',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case AdminOrderStatus.dibatalkan:
        return const SizedBox.shrink();
    }
  }
}
