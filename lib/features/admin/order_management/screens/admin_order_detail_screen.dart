import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/order_service.dart';
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

  void _showPrintReceiptModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_printshop_outlined,
                  color: AppColors.primaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Cetak Struk & Nota Kasir',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'BUKA BUKU',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Gerai Utama Buka Buku • Meja Kasir 1',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                  const Divider(height: 20),
                  Text('Pesanan: #${_currentOrder.orderId}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Pelanggan: ${_currentOrder.customerName}',
                      style: const TextStyle(fontSize: 12)),
                  Text('Tanggal: ${_currentOrder.orderDate ?? _currentOrder.orderTime}',
                      style: const TextStyle(fontSize: 12)),
                  const Divider(height: 16),
                  ..._currentOrder.books.map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${b.qty}x ${b.title}',
                              style: const TextStyle(fontSize: 12)),
                          Text('Rp ${b.price * b.qty}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('Rp ${_currentOrder.totalPrice}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mengirim perintah cetak ke Printer Kasir 58mm...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Cetak ke Printer Bluetooth/Thermal'),
            ),
          ],
        ),
      ),
    );
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
                onChatCustomer: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Membuka chat WhatsApp dengan ${_currentOrder.customerName}...',
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
        bottomNavigationBar: PickupActionBar(
          onPrintReceipt: _showPrintReceiptModal,
          onScanQr: _navigateToScanQrPickup,
          onChatCustomer: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Membuka chat dengan ${_currentOrder.customerName}...',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }
}
