import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/midtrans_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../admin/order_management/models/admin_order_detail.dart';
import '../../cart/screens/cart_screen.dart';
import '../../review/screens/write_review_screen.dart';
import '../models/order_model.dart';
import '../widgets/order_detail_book_item.dart';
import '../widgets/order_detail_stepper.dart';
import '../widgets/order_qr_pickup_modal.dart';
import 'pickup_success_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _currentOrder;
  OrderModel get order => _currentOrder;
  RealtimeChannel? _orderChannel;
  bool _isVerifyingPayment = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _subscribeToOrderUpdates();
    _refreshOrder();
  }

  @override
  void dispose() {
    _orderChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToOrderUpdates() {
    _orderChannel = OrderService.subscribeToOrderChanges(
      orderId: widget.order.id,
      onStatusChanged: (newStatus) {
        _refreshOrder();
      },
      onPaymentStatusChanged: (isPaid) {
        _refreshOrder();
      },
    );
  }

  Future<void> _refreshOrder() async {
    try {
      final updated = await OrderService.fetchOrderByIdForUser(widget.order.id);
      if (updated != null && mounted) {
        setState(() {
          _currentOrder = updated;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing order details: $e');
    }
  }

  Future<void> _verifyPaymentFromMidtrans() async {
    if (_isVerifyingPayment) return;
    setState(() => _isVerifyingPayment = true);

    try {
      // 1. Cek langsung ke status API Midtrans / Supabase
      final status = await MidtransService.checkTransactionStatus(_currentOrder.id);

      if (status.isPaid) {
        // Update database agar sinkron
        await OrderService.updateMidtransPaymentData(
          orderId: _currentOrder.id,
          isPaid: true,
          paymentType: status.paymentType,
          transactionStatus: status.transactionStatus,
          newStatus: AdminOrderStatus.diproses,
        );

        await _refreshOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Pembayaran berhasil diverifikasi! Pesanan kini sedang diproses.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  status.isPending ? Icons.hourglass_top_rounded : Icons.info_outline_rounded,
                  color: status.isPending ? Colors.orange : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  status.isPending ? 'Pembayaran Pending' : 'Status: ${status.transactionStatus}',
                  style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: Text(
              status.isPending
                  ? 'Status transaksi di Midtrans masih menunggu pembayaran. Jika Anda baru saja membayar, mohon tunggu sebentar lalu coba periksa kembali.'
                  : (status.statusMessage ?? 'Transaksi belum terverifikasi lunas di Midtrans.'),
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _verifyPaymentFromMidtrans();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cek Ulang'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kendala saat verifikasi Midtrans: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifyingPayment = false);
      }
    }
  }

  void _copyOrderId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _currentOrder.id.replaceAll('#', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text('Nomor pesanan ${_currentOrder.id} disalin!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final isReadyPickup = order.status == OrderStatus.readyPickup;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Detail Pesanan',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
        onProfilePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil pembaca Budi Darmawan.'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Toast / Notification Status Banner
              if (isReadyPickup) ...[
                _buildStatusBanner(),
                const SizedBox(height: 14),
              ],
              if (order.deliveryType == DeliveryType.delivery &&
                  order.status == OrderStatus.readyDelivery) ...[
                _buildReadyDeliveryStatusBanner(),
                const SizedBox(height: 14),
              ],
              if (order.deliveryType == DeliveryType.delivery &&
                  order.status == OrderStatus.shipping) ...[
                _buildShippingDeliveryStatusBanner(),
                const SizedBox(height: 14),
              ],
              if (order.status == OrderStatus.completed) ...[
                _buildCompletedStatusBanner(),
                const SizedBox(height: 14),
              ],
              if (order.status == OrderStatus.cancelled) ...[
                _buildCancelledStatusBanner(),
                const SizedBox(height: 14),
              ],

              // 2. Order Meta Identifier Card
              _buildOrderMetaCard(context),

              const SizedBox(height: 16),

              // 3. Featured Store Pickup Card & CTA (Priority for Pickup Orders)
              if (order.deliveryType == DeliveryType.pickup &&
                  order.status != OrderStatus.cancelled) ...[
                _buildStorePickupCard(context),
                const SizedBox(height: 16),
              ],

              // 3b. Featured Delivery Destination Card & "Pesanan Sampai" CTA (For Delivery Orders)
              if (order.deliveryType == DeliveryType.delivery &&
                  order.status != OrderStatus.cancelled) ...[
                _buildDeliveryDestinationCard(context),
                const SizedBox(height: 16),
              ],

              // 4. Status Perjalanan Buku (Timeline Stepper)
              if (order.timeline.isNotEmpty) ...[
                OrderDetailStepper(steps: order.timeline),
                const SizedBox(height: 16),
              ],

              // 5. Ordered Books Card (Rincian Buku)
              _buildOrderedBooksCard(context),

              const SizedBox(height: 16),

              // 6. Payment Summary Card (Ringkasan Pembayaran)
              _buildPaymentSummaryCard(),

              const SizedBox(height: 16),

              // 7. Store Assistance / Support Card
              _buildSupportCard(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 20,
              color: AppColors.onSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesanan Siap Diambil di Toko',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Paket buku telah dirapikan & siap di kasir toko.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyDeliveryStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DAEF).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8E44AD).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF8E44AD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paket Siap Dikirim Kurir Toko',
                  style: AppTypography.labelLg.copyWith(
                    color: const Color(0xFF5B2C6F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Buku telah selesai disiapkan & dikemas rapi. Menunggu kurir toko berangkat ke alamat Anda.',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF5B2C6F).withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingDeliveryStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              size: 20,
              color: AppColors.onSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurir Sedang Menuju Alamat Anda',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kurir toko kami sedang dalam perjalanan mengantarkan paket buku Anda.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondaryContainer.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledStatusBanner() {
    final isMidtrans = _currentOrder.paymentMethod.toLowerCase().contains('midtrans') ||
        _currentOrder.paymentMethod.toLowerCase().contains('qris') ||
        _currentOrder.paymentMethod.toLowerCase().contains('gateway');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Dibatalkan',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pembayaran pesanan ini sebelumnya belum terverifikasi atau sempat dibatalkan.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMidtrans) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sudah menyelesaikan pembayaran di Midtrans?',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tekan tombol di bawah untuk menyinkronkan status pembayaran settlement dari Midtrans.',
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: _isVerifyingPayment ? null : _verifyPaymentFromMidtrans,
                      icon: _isVerifyingPayment
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.verified_outlined, size: 18),
                      label: Text(
                        _isVerifyingPayment
                            ? 'Memeriksa Midtrans...'
                            : 'Verifikasi Ulang Pembayaran Midtrans',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 20,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesanan Telah Selesai',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.completionNote ??
                      'Buku telah diterima oleh pembaca. Terima kasih telah berbelanja di Buka Buku!',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderMetaCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nomor Pesanan',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    order.id,
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9999),
                      onTap: () => _copyOrderId(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.content_copy_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Waktu Pemesanan',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                order.orderDateExact,
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorePickupCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_library_rounded,
                  size: 22,
                  color: AppColors.onPrimaryFixed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.branchName ?? 'Gerai Utama Buka Buku',
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.branchAddress ??
                          'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat 10330',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.branchSchedule ?? 'Buka Hari Ini: 08.00 – 21.00 WIB',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Cashier instruction info box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  order.status == OrderStatus.completed
                      ? Icons.verified_rounded
                      : Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.status == OrderStatus.completed
                        ? 'Pesanan telah selesai diserahkan kepada pembaca di gerai ini.'
                        : 'Tunjukkan QR Code berikut kepada staf kasir saat mengambil pesanan fisik Anda.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                if (order.status == OrderStatus.completed) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PickupSuccessScreen(order: order),
                    ),
                  );
                } else {
                  OrderQrPickupModal.show(context, order);
                }
              },
              icon: Icon(
                order.status == OrderStatus.completed
                    ? Icons.verified_outlined
                    : Icons.qr_code_2_rounded,
                size: 20,
              ),
              label: Text(
                order.status == OrderStatus.completed
                    ? 'Lihat Bukti Pengambilan Buku'
                    : 'Lihat QR Pickup',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDestinationCard(BuildContext context) {
    final isShipping = order.status == OrderStatus.shipping;
    final isCompleted = order.status == OrderStatus.completed;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isShipping
              ? AppColors.secondary.withValues(alpha: 0.5)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Courier Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isShipping
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.two_wheeler_rounded,
                  size: 24,
                  color: isShipping ? AppColors.secondary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pengantaran Kurir Toko',
                          style: AppTypography.titleMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isShipping
                                ? AppColors.secondaryContainer
                                : (isCompleted
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : const Color(0xFFE8DAEF)),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            isShipping
                                ? 'Sedang Diantar'
                                : (isCompleted ? 'Selesai' : 'Siap Kirim'),
                            style: AppTypography.caption.copyWith(
                              color: isShipping
                                  ? AppColors.onSecondaryContainer
                                  : (isCompleted
                                      ? AppColors.success
                                      : const Color(0xFF7D3C98)),
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Penerima: ${order.customerName}${order.customerPhone != null && order.customerPhone!.isNotEmpty ? " • ${order.customerPhone}" : ""}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerAddress ?? 'Alamat pengantaran',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Status & Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isShipping
                  ? const Color(0xFFFAF7F2)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isShipping
                    ? AppColors.secondary.withValues(alpha: 0.3)
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCompleted
                      ? Icons.verified_rounded
                      : (isShipping
                          ? Icons.directions_bike_rounded
                          : Icons.inventory_2_outlined),
                  size: 18,
                  color: isCompleted
                      ? AppColors.success
                      : (isShipping
                          ? AppColors.secondary
                          : const Color(0xFF7D3C98)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCompleted
                        ? 'Pesanan buku telah sampai dan diterima dengan baik. Terima kasih!'
                        : (isShipping
                            ? 'Kurir toko kami sedang menuju ke alamat Anda. Silakan tekan tombol "Pesanan Sudah Sampai" di bawah jika buku sudah diterima.'
                            : 'Paket buku Anda telah dikemas dan segera diberangkatkan oleh kurir toko.'),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Button: "Pesanan Sudah Sampai" ONLY when status == shipping
          if (isShipping) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showConfirmReceivedDialog,
                icon: const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(
                  'Pesanan Sudah Sampai',
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConfirmReceivedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pesanan Sampai?',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Pastikan Anda telah menerima paket buku dari kurir toko dengan kondisi baik. Tekan "Ya, Sudah Sampai" untuk menyelesaikan pesanan ini.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await OrderService.markDeliveryReceived(_currentOrder.id);
                await _refreshOrder();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pesanan berhasil diselesaikan! Selamat membaca buku Anda.',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengonfirmasi pesanan: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Sudah Sampai'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderedBooksCard(BuildContext context) {
    final bookCount = order.items.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rincian Buku',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$bookCount Item',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: AppColors.surfaceContainer,
                height: 1,
                thickness: 1,
              ),
            ),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return OrderDetailBookItem(
                item: item,
                onWriteReview: order.status == OrderStatus.completed
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WriteReviewScreen(
                              bookId: item.bookId ?? '',
                              bookTitle: item.title,
                              bookAuthor: item.author,
                              bookCoverUrl: item.coverUrl,
                              orderId: order.id,
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          ),
          if (order.status == OrderStatus.completed && order.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final count = await OrderService.reAddItemsToCart(order.items);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$count buku telah ditambahkan ke keranjang belanja!',
                        ),
                        backgroundColor: AppColors.primaryContainer,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        action: SnackBarAction(
                          label: 'Lihat Keranjang',
                          textColor: AppColors.secondary,
                          onPressed: () {
                            AppNavigation.hideCurrentSnackBar();
                            AppNavigation.push(
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.repeat_rounded, size: 20),
                label: const Text('Beli Lagi Semua Buku'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Pembayaran',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'QRIS Lunas',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Subtotal Buku
          _buildPaymentRow(
            label: 'Subtotal Buku (${order.items.length} item)',
            value: order.subtotal,
            isSecondary: false,
          ),

          // Voucher (if any)
          if (order.voucherCode != null && order.voucherDiscount != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.sell_outlined,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Voucher (${order.voucherCode})',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  order.voucherDiscount!,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Self-Pickup
          _buildPaymentRow(
            label: 'Pengambilan di Toko (Self-Pickup)',
            value: order.shippingCost,
            isSecondary: true,
          ),

          const SizedBox(height: 8),

          // Service Fee
          _buildPaymentRow(
            label: 'Biaya Layanan Aplikasi',
            value: order.serviceFee,
            isSecondary: false,
          ),

          const SizedBox(height: 14),
          Divider(
            color: AppColors.surfaceContainer,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 14),

          // Total Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Metode: ${order.paymentMethod}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Text(
                order.totalAmount,
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    required bool isSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMd.copyWith(
            color: isSecondary ? AppColors.secondary : AppColors.onSurface,
            fontWeight: isSecondary ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Butuh bantuan pesanan?',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Pustakawan kami siap membantu',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Menghubungi Pustakawan Buka Buku terkait pesanan ${order.id}...',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
            label: const Text('WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
