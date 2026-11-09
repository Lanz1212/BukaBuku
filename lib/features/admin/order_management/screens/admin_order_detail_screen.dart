import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/cashier_log_service.dart';
import '../../scan_qr_pickup/screens/scan_qr_pickup_screen.dart';
import '../models/admin_order_detail.dart';
import '../widgets/detail/book_list_section.dart';
import '../widgets/detail/customer_info_section.dart';
import '../widgets/detail/order_flow_section.dart';
import '../widgets/detail/order_header_card.dart';
import '../widgets/detail/payment_info_section.dart';
import '../widgets/detail/pickup_action_bar.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final AdminOrderDetail order;

  const AdminOrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  late AdminOrderDetail _currentOrder;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  void _updateStatus(AdminOrderStatus newStatus) async {
    setState(() {
      _currentOrder = _currentOrder.copyWith(status: newStatus);
    });

    try {
      await OrderService.updateOrderStatus(_currentOrder.orderId, newStatus);
      CashierLogService.recordLog(
        action: 'Pembaruan Status Pesanan',
        details: 'Status pesanan #${_currentOrder.orderId} diubah menjadi: ${_currentOrder.statusLabel}',
        orderId: _currentOrder.orderId,
        tag: 'Pesanan',
      );
    } catch (e) {
      debugPrint('Error updating order status in Supabase: $e');
    }
  }

  void _navigateToScanQrPickup() async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => ScanQrPickupScreen(
          preloadedOrder: _currentOrder,
        ),
      ),
    );

    if (result is AdminOrderDetail) {
      setState(() {
        _currentOrder = result;
      });
    } else if (result == true) {
      _updateStatus(AdminOrderStatus.selesai);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Return updated order on pop
      },
      child: Scaffold(
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
            onPressed: () => Navigator.pop(context, _currentOrder),
          ),
          titleSpacing: 0,
          title: Text(
            'Detail Pesanan Admin',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontSize: 16.5,
            ),
          ),
          actions: [
            // Staff Role Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBE8E3),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 13,
                    color: Color(0xFF6B655F),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Staff',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF6B655F),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Torch Toggle Button
            IconButton(
              icon: Icon(
                _isTorchOn
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_on_outlined,
                size: 20,
                color: _isTorchOn ? const Color(0xFFD99A35) : AppColors.outline,
              ),
              tooltip: 'Senter Scanner',
              onPressed: () {
                setState(() {
                  _isTorchOn = !_isTorchOn;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isTorchOn
                        ? 'Senter scanner aktif'
                        : 'Senter scanner nonaktif'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Camera / Quick Scan Button
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                size: 20,
                color: AppColors.onSurface,
              ),
              tooltip: 'Kamera Scanner',
              onPressed: _navigateToScanQrPickup,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card with ID & Status
              OrderHeaderCard(order: _currentOrder),
              const SizedBox(height: 14),

              // 2. Customer Info Section
              CustomerInfoSection(
                order: _currentOrder,
                onCallCustomer: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Menghubungi ${_currentOrder.customerPhone}...',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 3. Book List Section
              BookListSection(order: _currentOrder),
              const SizedBox(height: 14),

              // 4. Payment Info Section
              PaymentInfoSection(order: _currentOrder),
              const SizedBox(height: 14),

              // 5. Order Management Flow Section
              OrderFlowSection(
                order: _currentOrder,
                onScanQr: _navigateToScanQrPickup,
                onStatusChanged: _updateStatus,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final isDelivery = _currentOrder.deliveryType.toLowerCase().contains('kurir');
            if (isDelivery) {
              String label;
              IconData icon;
              Color color;
              VoidCallback action;
              bool isDisabled = false;

              switch (_currentOrder.status) {
                case AdminOrderStatus.baru:
                  label = 'Mulai Siapkan Buku';
                  icon = Icons.check_circle_outline_rounded;
                  color = AppColors.primaryContainer;
                  action = () => _updateStatus(AdminOrderStatus.diproses);
                  break;
                case AdminOrderStatus.diproses:
                  label = 'Paket Siap Dikirim';
                  icon = Icons.inventory_2_outlined;
                  color = const Color(0xFF8E44AD);
                  action = () => _updateStatus(AdminOrderStatus.siapDikirim);
                  break;
                case AdminOrderStatus.siapDiambil:
                  label = 'Siap Diambil di Toko';
                  icon = Icons.storefront_rounded;
                  color = AppColors.success;
                  action = _navigateToScanQrPickup;
                  break;
                case AdminOrderStatus.siapDikirim:
                  label = 'Serahkan ke Kurir';
                  icon = Icons.two_wheeler_rounded;
                  color = AppColors.secondary;
                  action = () => _updateStatus(AdminOrderStatus.dalamPengiriman);
                  break;
                case AdminOrderStatus.dalamPengiriman:
                  label = 'Kurir Sedang Mengantar';
                  icon = Icons.two_wheeler_rounded;
                  color = const Color(0xFF6B655F);
                  action = () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Kurir toko sedang dalam perjalanan ke alamat pembeli. Menunggu pembeli menekan "Pesanan Sudah Sampai".',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  };
                  break;
                case AdminOrderStatus.selesai:
                  label = 'Telah Diterima Pembeli';
                  icon = Icons.check_circle_rounded;
                  color = const Color(0xFF2E7D32);
                  action = () {};
                  isDisabled = true;
                  break;
                case AdminOrderStatus.dibatalkan:
                  label = 'Pesanan Dibatalkan';
                  icon = Icons.cancel_outlined;
                  color = AppColors.error;
                  action = () {};
                  isDisabled = true;
                  break;
              }

              return PickupActionBar(
                onScanQr: action,
                customScanLabel: label,
                customIcon: icon,
                buttonColor: color,
                isDisabled: isDisabled,
              );
            }

            final isCompleted = _currentOrder.status == AdminOrderStatus.selesai;
            return PickupActionBar(
              onScanQr: isCompleted ? () {} : _navigateToScanQrPickup,
              customScanLabel: isCompleted ? 'Pesanan Telah Selesai' : null,
              customIcon: isCompleted ? Icons.check_circle_rounded : null,
              isDisabled: isCompleted,
            );
          },
        ),
      ),
    );
  }
}
