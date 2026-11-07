import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../models/order_model.dart';
import '../widgets/qr_pickup_code_display.dart';
import '../widgets/qr_pickup_order_meta.dart';
import '../widgets/qr_pickup_store_card.dart';
import 'order_detail_screen.dart';
import 'pickup_success_screen.dart';

class QrPickupScreen extends StatefulWidget {
  final OrderModel? order;

  const QrPickupScreen({
    super.key,
    this.order,
  });

  @override
  State<QrPickupScreen> createState() => _QrPickupScreenState();
}

class _QrPickupScreenState extends State<QrPickupScreen> {
  RealtimeChannel? _realtimeChannel;
  OrderModel? _currentOrder;
  bool _isLoading = false;
  bool _isSavedToGallery = false;

  OrderModel get _order => _currentOrder ?? widget.order ?? mockOrders.first;

  bool get _isReady =>
      _order.status == OrderStatus.readyPickup ||
      _order.status == OrderStatus.completed;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _initOrderAndRealtime();
  }

  Future<void> _initOrderAndRealtime() async {
    // If order was not provided, attempt to fetch latest pickup order from DB
    if (_currentOrder == null) {
      setState(() => _isLoading = true);
      final orders = await OrderService.fetchCustomerOrders();
      if (!mounted) return;
      final pickupOrder = orders.firstWhere(
        (o) => o.deliveryType == DeliveryType.pickup,
        orElse: () => orders.isNotEmpty ? orders.first : mockOrders.first,
      );
      setState(() {
        _currentOrder = pickupOrder;
        _isLoading = false;
      });
    }

    final current = _order;
    final cleanId = current.id.replaceAll('#', '').trim();

    // If order is already completed, redirect immediately to PickupSuccessScreen
    if (current.status == OrderStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PickupSuccessScreen(order: current),
          ),
        );
      });
      return;
    }

    if (cleanId.isNotEmpty) {
      _realtimeChannel = OrderService.subscribeToOrderChanges(
        orderId: cleanId,
        onStatusChanged: (newStatus) async {
          debugPrint('Realtime status update received for order $cleanId: $newStatus');
          if (newStatus == 'selesai') {
            final freshOrder = await OrderService.fetchOrderByIdForUser(cleanId);
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PickupSuccessScreen(order: freshOrder ?? _order),
              ),
            );
          } else if (newStatus == 'siapDiambil') {
            final freshOrder = await OrderService.fetchOrderByIdForUser(cleanId);
            if (!mounted) return;
            setState(() {
              if (freshOrder != null) {
                _currentOrder = freshOrder;
              }
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _triggerSaveAnimation() {
    setState(() {
      _isSavedToGallery = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code berhasil disimpan ke galeri foto'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryContainer,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSavedToGallery = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: BookstoreAppBar(
          title: 'Qr Pickup',
          showBackButton: true,
          onBackPressed: () => Navigator.of(context).maybePop(),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Qr Pickup',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real DB Status Banner (replaces manual toggle switcher)
              _buildStateBanner(),

              const SizedBox(height: 16),

              // Screen Header Narrative
              Row(
                children: [
                  const Icon(
                    Icons.storefront,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LAYANAN AMBIL DI TOKO',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'QR Pickup',
                style: AppTypography.headlineLg.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tunjukkan kode ini kepada kasir saat mengambil pesanan di toko.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic Body: Ready View OR Locked View based on real DB status
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isReady ? _buildReadyView() : _buildLockedView(),
              ),

              const SizedBox(height: 24),

              // Curated Store Visual Banner
              _buildStoreBanner(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateBanner() {
    final bool isReady = _isReady;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isReady
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle_rounded : Icons.schedule_rounded,
            size: 18,
            color: isReady ? AppColors.success : AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isReady
                  ? 'Pesanan Siap Diambil di Meja Kasir Toko'
                  : 'Pesanan Sedang Disiapkan oleh Kurator Toko',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: isReady ? AppColors.success : AppColors.secondary,
                fontSize: 12.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isReady
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              isReady ? 'Siap' : 'Proses',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: isReady ? AppColors.success : AppColors.secondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyView() {
    return Column(
      key: const ValueKey('ready_view'),
      children: [
        // Ticket Pass Card Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              QrPickupStoreCard(
                storeName: _order.branchName ?? 'Gerai Utama Buka Buku',
                deskName: 'Meja Kasir Pengambilan',
                orderId: _order.id,
                customerName: _order.customerName,
              ),
              QrPickupCodeDisplay(
                qrData: _order.qrCode.isNotEmpty ? _order.qrCode : _order.id,
              ),
              QrPickupOrderMeta(
                itemCountText: '${_order.items.length} Buku Fisik',
                bookTitlesText: _order.items.map((i) => i.title).join(' • '),
                totalAmount: _order.totalAmount,
                paymentStatus: '${_order.paymentMethod} • ${_order.isPaid ? "Lunas" : "Menunggu"}',
                pickupLocation: _order.pickupLocation ??
                    'Meja Kasir 1, Gerai Utama Buka Buku',
                pickupSchedule: _order.pickupSchedule ??
                    'Buka Hari Ini: 08.00 - 21.00 WIB',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Instruction Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tunjukkan QR Code ini kepada kasir saat mengambil pesanan. Kasir akan memindai kode untuk menyerahkan buku Anda.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Actions Bar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: _order),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Lihat Detail Pesanan',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        TextButton(
          onPressed: _triggerSaveAnimation,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSavedToGallery ? Icons.check : Icons.download_rounded,
                size: 18,
                color: _isSavedToGallery
                    ? AppColors.success
                    : AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                _isSavedToGallery
                    ? 'Tersimpan di Galeri!'
                    : 'Simpan QR ke Galeri',
                style: AppTypography.labelMd.copyWith(
                  color: _isSavedToGallery
                      ? AppColors.success
                      : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedView() {
    return Container(
      key: const ValueKey('locked_view'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Big Lock Graphic
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 32,
                    color: AppColors.primaryContainer,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.hourglass_top,
                      size: 13,
                      color: AppColors.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              'Sedang Dipersiapkan Kurator',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSecondaryFixedVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'QR Pickup belum tersedia.',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            'QR Pickup akan muncul secara otomatis setelah kurator kami selesai menyiapkan pesanan Anda dan status berubah menjadi Siap Diambil.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Progress Capsule Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.schedule,
                        size: 18,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Persiapan',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'Pengecekan Kualitas Buku',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
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
                      'Estimasi',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '~15 menit',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Book Glance Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 38,
                  height: 52,
                  child: Image.network(
                    _order.summaryCoverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(
                        Icons.menu_book,
                        size: 20,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.items.isNotEmpty
                          ? (_order.items.length > 1
                              ? '${_order.items.first.title} & ${_order.items.length - 1} lainnya'
                              : _order.items.first.title)
                          : _order.summaryTitle,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sedang dibungkus rapi',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: AppColors.secondary,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Notification Alert Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kirim notifikasi saat siap?',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifikasi push & WhatsApp diaktifkan!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Text(
                    'Aktifkan',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuD2zeUK23BRP7ZPj8Z9Pf0Ck2zN0NkAWAjx4gIRHPM-Y6iNNWHBhWXjB4HgxU57DuIFwDolPUcAa6ClP8_3Afm9-laiqiuNJkX7gQ_-bCOH0JIks28mkkT4qUzkT9BkkrtSmEJtF86KGku2HyBQfI9TBoxTWI3shRY3xXnzw0Wm2hCd2Z0P3awdx5LvtR828lUtzhn7CVGoanFSRYOLPfBeMuRw4u7aCDUxAxsGUzTZWI4htfg2GBt7vw',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gerai Utama Buka Buku',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jl. Cikini Raya No. 45, Jakarta Pusat',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menghubungi Meja Kasir Buka Buku...'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.primaryContainer,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.call_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
