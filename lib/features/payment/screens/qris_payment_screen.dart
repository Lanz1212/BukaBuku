import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/payment_simulation_state.dart';
import '../widgets/payment_app_bar.dart';
import '../widgets/payment_trust_badges.dart';
import '../widgets/qris_code_card.dart';
import '../widgets/qris_countdown_banner.dart';
import '../widgets/qris_guide_accordion.dart';
import '../widgets/qris_order_header_card.dart';
import '../widgets/qris_simulation_bar.dart';
import '../widgets/qris_status_views.dart';

/// Screen 2: Halaman Pembayaran Online QRIS
/// Conforms to DESIGN.md, AppColors, AppTypography, and Stitch screen 9fd9b16950e747439b6f91a11ffffb87.
class QrisPaymentScreen extends StatefulWidget {
  final String orderId;
  final int totalAmount;
  final String merchantName;
  final String nmid;

  const QrisPaymentScreen({
    super.key,
    this.orderId = '#ORD00125',
    this.totalAmount = 181000,
    this.merchantName = 'Toko Buku Budi Cikini',
    this.nmid = 'NMID: ID1020038891002',
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  PaymentSimulationStatus _currentStatus = PaymentSimulationStatus.pending;

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  void _onConfirmPaid() {
    setState(() {
      _currentStatus = PaymentSimulationStatus.success;
    });
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Batalkan Pembayaran?',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Pesanan ${widget.orderId} akan dibatalkan. Anda dapat memesan ulang buku pilihan Anda kapan saja.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Lanjut Bayar',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: AppColors.error,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  void _showReceiptDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Struk Pembayaran Resmi',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toko Buku Budi Cikini • Bukti Transaksi QRIS',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Divider(height: 28, color: AppColors.outlineVariant),
              _receiptRow('Nomor Pesanan', widget.orderId),
              const SizedBox(height: 8),
              _receiptRow('ID Transaksi', 'TRX-99482103B'),
              const SizedBox(height: 8),
              _receiptRow('Metode', 'QRIS BI Standar'),
              const SizedBox(height: 8),
              _receiptRow('Waktu Bayar', 'Hari ini, 15:42 WIB'),
              const SizedBox(height: 8),
              _receiptRow('Status', 'Lunas (Diterima)', isSuccess: true),
              const Divider(height: 28, color: AppColors.outlineVariant),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: AppTypography.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    _formatRupiah(widget.totalAmount),
                    style: AppTypography.headlineMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup Struk',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _receiptRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: isSuccess ? const Color(0xFF3F8F5F) : AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PaymentAppBar(
        title: 'Pembayaran',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Simulation Mode Switcher Bar
              QrisSimulationBar(
                currentStatus: _currentStatus,
                onStatusChanged: (status) {
                  setState(() {
                    _currentStatus = status;
                  });
                },
              ),

              const SizedBox(height: 12),

              // 2. Order Summary Header Card (#ORD00125 & Rp181.000)
              QrisOrderHeaderCard(
                orderId: widget.orderId,
                totalAmount: widget.totalAmount,
                paymentMethodLabel: 'QRIS Digital',
              ),

              const SizedBox(height: 16),

              // 3. Dynamic State View Display
              if (_currentStatus == PaymentSimulationStatus.pending) ...[
                // Countdown Timer Banner
                QrisCountdownBanner(
                  initialMinutes: 15,
                  onTimerExpired: () {
                    setState(() {
                      _currentStatus = PaymentSimulationStatus.expired;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // QRIS Code Display Card
                QrisCodeCard(
                  merchantName: widget.merchantName,
                  nmid: widget.nmid,
                ),

                const SizedBox(height: 16),

                // 5-Step Payment Guide Card
                QrisGuideAccordion(
                  merchantName: 'Toko Buku Budi',
                  formattedAmount: _formatRupiah(widget.totalAmount),
                ),

                const SizedBox(height: 20),

                // Primary & Secondary Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _onConfirmPaid,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Saya Sudah Membayar',
                      style: AppTypography.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _showCancelConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainer,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Batalkan Pembayaran',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ] else if (_currentStatus == PaymentSimulationStatus.success) ...[
                QrisSuccessView(
                  totalAmount: widget.totalAmount,
                  onBackToHome: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  onViewReceipt: _showReceiptDialog,
                ),
              ] else if (_currentStatus == PaymentSimulationStatus.failed) ...[
                QrisFailedView(
                  onRetry: () {
                    setState(() {
                      _currentStatus = PaymentSimulationStatus.pending;
                    });
                  },
                  onSelectOtherMethod: () {
                    Navigator.of(context).pop();
                  },
                ),
              ] else if (_currentStatus == PaymentSimulationStatus.expired) ...[
                QrisExpiredView(
                  onRefreshQR: () {
                    setState(() {
                      _currentStatus = PaymentSimulationStatus.pending;
                    });
                  },
                  onBackToCart: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],

              // 4. Security & Bookstore Heritage Footer
              const PaymentSecurityFooter(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
