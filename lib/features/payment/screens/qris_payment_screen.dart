import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/order_service.dart';
import '../../admin/order_management/models/admin_order_detail.dart';
import '../models/payment_simulation_state.dart';
import '../widgets/payment_app_bar.dart';
import '../widgets/payment_trust_badges.dart';
import '../widgets/qris_code_card.dart';
import '../widgets/qris_countdown_banner.dart';
import '../widgets/qris_guide_accordion.dart';
import '../widgets/qris_order_header_card.dart';
import '../widgets/qris_status_views.dart';
import 'payment_success_screen.dart';
import '../widgets/payment_success_bento_card.dart';

/// Screen 2: Halaman Pembayaran Online QRIS
/// Conforms to DESIGN.md, AppColors, AppTypography, and Stitch screen 9fd9b16950e747439b6f91a11ffffb87.
class QrisPaymentScreen extends StatefulWidget {
  final String orderId;
  final int totalAmount;
  final String merchantName;
  final String nmid;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final List<AdminOrderBookItem>? orderedBooks;

  const QrisPaymentScreen({
    super.key,
    this.orderId = '#ORD00125',
    this.totalAmount = 181000,
    this.merchantName = 'Toko Buku Budi Cikini',
    this.nmid = 'NMID: ID1020038891002',
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.orderedBooks,
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

  void _onConfirmPaid() async {
    final cleanId = widget.orderId.replaceAll('#', '').trim();
    try {
      await OrderService.updateOrderPaymentStatus(cleanId, true);
    } catch (e) {
      debugPrint('Error updating order payment status in Supabase: $e');
    }
    if (mounted) {
      setState(() {
        _currentStatus = PaymentSimulationStatus.success;
      });
    }
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
                  merchantName: 'Buka Buku',
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
                  onViewReceipt: () {
                    final receiptBooks = widget.orderedBooks != null &&
                            widget.orderedBooks!.isNotEmpty
                        ? widget.orderedBooks!.map((b) {
                            return PaymentSuccessItem(
                              title: b.title,
                              subtitle: '${b.author} • ${b.qty}x',
                              price: 'Rp${b.price}',
                              imageUrl: b.imageUrl ?? '',
                            );
                          }).toList()
                        : const [
                            PaymentSuccessItem(
                              title: 'Atomic Habits',
                              subtitle: 'James Clear • 1x Hardcover',
                              price: 'Rp108.000',
                              imageUrl:
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDuro3027OrnxnzHhMWNNhxlL6yQ7uRMP4gN56vlkj8gMZdzZ7-U7J-AiMpN9z6agF63Q5IceDcr-ELrDh46dR-dg4sNIRfuvNTfmG0GDGb1H-GjJyb3nBFfSVJREh0B_fT9xfanJsispJlPm4rdAP3oZObX-VkWht5KFxVjOdeqFAeGSlto5ORp0V83N93AtcA-drkc4EIiM7dyJbCUw7h8pSJesulR-EIhER1dmhq5uEeNEB6zrFljQ',
                            ),
                          ];

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessScreen(
                          orderId: widget.orderId,
                          totalAmount: widget.totalAmount,
                          customerPhone:
                              widget.customerPhone ?? '0812-3456-7890',
                          deliveryAddress: widget.deliveryAddress ??
                              'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat',
                          books: receiptBooks,
                        ),
                      ),
                    );
                  },
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
