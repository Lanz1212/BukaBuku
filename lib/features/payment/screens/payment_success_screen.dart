import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/order_service.dart';
import '../../order/models/order_model.dart';
import '../../order/screens/order_detail_screen.dart';
import '../widgets/payment_success_bento_card.dart';
import '../widgets/payment_success_hero.dart';
import '../widgets/payment_success_wa_banner.dart';

/// Halaman Pembayaran Berhasil (Status Transaksi)
/// Menampilkan data pesanan riil dari Supabase database, bebas dari data dummy.
class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final int? totalAmount;
  final String? paymentTime;
  final String? paymentMethod;
  final List<PaymentSuccessItem>? books;
  final String? deliveryTitle;
  final String? deliveryAddress;
  final String? customerPhone;
  final VoidCallback? onViewOrderPressed;
  final VoidCallback? onBackToHomePressed;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    this.totalAmount,
    this.paymentTime,
    this.paymentMethod,
    this.books,
    this.deliveryTitle,
    this.deliveryAddress,
    this.customerPhone,
    this.onViewOrderPressed,
    this.onBackToHomePressed,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealOrder();
  }

  Future<void> _loadRealOrder() async {
    try {
      final cleanId = widget.orderId.replaceAll('#', '').trim();
      final order = await OrderService.fetchOrderByIdForUser(cleanId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading real order in PaymentSuccessScreen: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryContainer),
        ),
      );
    }

    final order = _order;
    final isDelivery = order != null
        ? (order.deliveryType == DeliveryType.delivery)
        : (widget.deliveryTitle?.toLowerCase().contains('kurir') ?? false);

    final resolvedAmount = order?.totalAmountValue ?? widget.totalAmount ?? 0;
    final resolvedTime = order?.orderDateExact.isNotEmpty == true
        ? order!.orderDateExact
        : (widget.paymentTime ?? 'Hari ini');
    final resolvedMethod = order?.paymentMethod ?? widget.paymentMethod ?? 'Midtrans Payment';
    final resolvedAddress = order?.customerAddress ??
        order?.branchAddress ??
        widget.deliveryAddress ??
        (isDelivery ? 'Alamat pengantaran pembaca' : 'Gerai Utama Buka Buku Cikini');
    final resolvedPhone = order?.customerPhone ?? widget.customerPhone ?? '0812-3456-7890';

    List<PaymentSuccessItem> displayBooks = [];
    if (order != null && order.items.isNotEmpty) {
      displayBooks = order.items.map((item) {
        return PaymentSuccessItem(
          title: item.title,
          subtitle: '${item.author.isNotEmpty ? "${item.author} • " : ""}${item.quantity}x',
          price: item.subtotal,
          imageUrl: item.coverUrl,
        );
      }).toList();
    } else if (widget.books != null && widget.books!.isNotEmpty) {
      displayBooks = widget.books!;
    } else if (order != null) {
      displayBooks = [
        PaymentSuccessItem(
          title: order.summaryTitle,
          subtitle: order.summarySubtitle,
          price: order.totalAmount,
          imageUrl: order.summaryCoverUrl,
        ),
      ];
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Minimalist Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Status Transaksi',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.onBackToHomePressed != null) {
                        widget.onBackToHomePressed!();
                      } else {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Hero Section
                    const PaymentSuccessHero(),

                    const SizedBox(height: 12),

                    // Main Bento Transaction Summary Card
                    PaymentSuccessBentoCard(
                      totalAmount: resolvedAmount,
                      orderId: widget.orderId,
                      paymentTime: resolvedTime,
                      paymentMethod: resolvedMethod,
                      books: displayBooks,
                      deliveryTitle: isDelivery ? 'Kurir Antar ke Rumah' : 'Ambil di Toko',
                      deliveryAddress: resolvedAddress,
                    ),

                    const SizedBox(height: 12),

                    // WhatsApp Delivery Notice Banner
                    if (resolvedPhone.isNotEmpty && resolvedPhone != '-')
                      PaymentSuccessWaBanner(
                        phoneNumber: resolvedPhone,
                      ),

                    const SizedBox(height: 20),

                    // Bottom Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onViewOrderPressed != null) {
                            widget.onViewOrderPressed!();
                          } else if (order != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailScreen(order: order),
                              ),
                            );
                          } else {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Pesanan',
                              style: AppTypography.labelLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.onBackToHomePressed != null) {
                            widget.onBackToHomePressed!();
                          } else {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Beranda',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
