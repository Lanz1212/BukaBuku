import 'package:flutter/material.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/cashier_log_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../order_management/models/admin_order_detail.dart';
import '../../pickup_success/screens/pickup_success_screen.dart';
import '../models/qr_scan_result.dart';
import '../widgets/qr_cashier_checklist.dart';
import '../widgets/qr_payment_status_banner.dart';
import '../widgets/qr_result_book_list.dart';
import '../widgets/qr_result_header_card.dart';
import '../widgets/scan_scenario_tabs.dart';

class QrScanResultScreen extends StatefulWidget {
  final QrScanResult result;

  const QrScanResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<QrScanResultScreen> createState() => _QrScanResultScreenState();
}

class _QrScanResultScreenState extends State<QrScanResultScreen> {
  ScanScenario _scenario = ScanScenario.validOnline;
  bool _checklistPassed = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final order = _order;
    if (!order.isPaid || order.paymentMethod.toLowerCase().contains('kasir')) {
      _scenario = ScanScenario.validCash;
    } else {
      _scenario = ScanScenario.validOnline;
    }
  }

  AdminOrderDetail get _order {
    if (widget.result.fullOrder != null) {
      return widget.result.fullOrder!;
    }
    return AdminOrderDetail.mockOrders.first;
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F5),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Hasil Scan Qr',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryContainer,
              child: const Text(
                'K1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gerai & Terminal Strip
                    _buildStoreTerminalStrip(),
                    const SizedBox(height: 14),

                    // Demo Scenario Tabs
                    ScanScenarioTabs(
                      selectedScenario: _scenario,
                      onScenarioChanged: (sc) {
                        setState(() {
                          _scenario = sc;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // QR Valid Header Card
                    QrResultHeaderCard(
                      orderId: widget.result.orderId,
                      scanTime: 'Hari ini, 10:45 WIB',
                      scenario: _scenario,
                    ),
                    const SizedBox(height: 14),

                    // Customer Card
                    _buildCustomerCard(order),
                    const SizedBox(height: 14),

                    // Book List with Racks & Summary
                    QrResultBookList(
                      books: order.books,
                      totalPrice: widget.result.totalPrice,
                    ),
                    const SizedBox(height: 14),

                    // Payment Banner
                    QrPaymentStatusBanner(
                      scenario: _scenario,
                      formattedTotal: widget.result.formattedPrice,
                    ),
                    const SizedBox(height: 14),

                    // Cashier Checklist
                    QrCashierChecklist(
                      totalItemCount: widget.result.bookCount,
                      onAllChecked: (passed) {
                        setState(() {
                          _checklistPassed = passed;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Fixed Action Bar
            _buildBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreTerminalStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                size: 16,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                'Gerai Buka Buku • Meja Kasir 1',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Terminal Online',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(AdminOrderDetail order) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.secondaryContainer,
                child: Text(
                  order.customerInitials,
                  style: TextStyle(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
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
                          order.customerName,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Member Reguler',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.customerPhone,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            height: 1,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Titik Pengambilan: Gerai Buka Buku (Kasir 1)',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final bool isInvalid = _scenario == ScanScenario.invalidQr;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isInvalid
                  ? AppColors.outlineVariant
                  : AppColors.primaryContainer,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: (isInvalid || _isSubmitting)
                ? null
                : () async {
                    if (!_checklistPassed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Harap lengkapi pemeriksaan fisik buku sebelum konfirmasi!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    setState(() => _isSubmitting = true);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final cleanId = _order.orderId.replaceAll('#', '').trim();

                    try {
                      // 1. Update status pesanan di database Supabase menjadi selesai
                      await OrderService.updateOrderStatus(
                        cleanId,
                        AdminOrderStatus.selesai,
                        setPickupConfirmed: true,
                      );

                      // Catat ke log aktivitas kasir Supabase
                      CashierLogService.recordLog(
                        action: 'Validasi QR Pickup & Serah Terima',
                        details: 'Pesanan #${_order.orderId} selesai diserahkan kepada ${_order.customerName}',
                        orderId: _order.orderId,
                        tag: 'Pickup',
                      );

                      // 2. Broadcast notifikasi verifikasi scan QR berhasil ke admin
                      try {
                        await AdminNotificationService.broadcastToAdmins(
                          type: 'qrScanSuccess',
                          category: 'order',
                          title: 'Scan QR Pickup Berhasil ✅',
                          body: 'Pesanan #${_order.orderId} (${_order.customerName}) telah selesai diverifikasi QR dan diserahkan di kasir.',
                          orderId: cleanId,
                        );
                      } catch (e) {
                        debugPrint('Error broadcasting QR scan success notification: $e');
                      }

                      // 2. Jika bayar tunai di kasir, tandai is_paid = true
                      if (!_order.isPaid || _scenario == ScanScenario.validCash) {
                        await OrderService.updateOrderPaymentStatus(
                          cleanId,
                          true,
                          paymentMethod: 'Bayar di Kasir (Tunai)',
                          newStatus: AdminOrderStatus.selesai,
                          setPickupConfirmed: true,
                        );
                      }

                      if (!mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Pesanan $cleanId berhasil diserahkan!',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      final now = DateTime.now();
                      const monthNames = [
                        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                      ];
                      final day = now.day.toString().padLeft(2, '0');
                      final month = monthNames[now.month - 1];
                      final year = now.year;
                      final hour = now.hour.toString().padLeft(2, '0');
                      final minute = now.minute.toString().padLeft(2, '0');
                      final formattedNow = '$day $month $year • $hour:$minute WIB';

                      final updatedOrder = _order.copyWith(
                        status: AdminOrderStatus.selesai,
                        isPaid: true,
                        paymentMethod: (!_order.isPaid || _scenario == ScanScenario.validCash)
                            ? 'Bayar di Kasir (Tunai)'
                            : _order.paymentMethod,
                      );
                      final updatedResult = QrScanResult(
                        orderId: widget.result.orderId,
                        customerName: widget.result.customerName,
                        bookCount: widget.result.bookCount,
                        totalPrice: widget.result.totalPrice,
                        status: 'Selesai',
                        verificationTime: widget.result.verificationTime,
                        fullOrder: updatedOrder,
                      );

                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PickupSuccessScreen(
                            result: updatedResult,
                            kasirName: 'Kasir 1',
                            pickupTime: formattedNow,
                          ),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error updating pickup status in Supabase: $e');
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Gagal memperbarui status di server: $e'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _scenario == ScanScenario.validCash
                            ? 'Konfirmasi Bayar Cash & Serahkan'
                            : 'Konfirmasi Pengambilan',
                        style: AppTypography.labelLg.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            child: Text(
              'Batalkan / Pindai Ulang',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
