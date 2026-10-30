import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_order_detail.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_summary_bar.dart';
import 'admin_order_detail_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  late List<AdminOrderDetail> _orders;
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: Semua, 1: Baru, 2: Diproses, 3: Siap Diambil, 4: Dikirim

  @override
  void initState() {
    super.initState();
    _orders = List.from(AdminOrderDetail.mockOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _countBaru =>
      _orders.where((o) => o.status == AdminOrderStatus.baru).length;

  int get _countDiproses =>
      _orders.where((o) => o.status == AdminOrderStatus.diproses).length;

  int get _countSiapDiambil =>
      _orders.where((o) => o.status == AdminOrderStatus.siapDiambil).length;

  int get _countDikirim =>
      _orders.where((o) => o.status == AdminOrderStatus.dalamPengiriman).length;

  int get _totalNeedAction =>
      _countBaru + _countDiproses + _countSiapDiambil;

  List<AdminOrderDetail> get _filteredOrders {
    final query = _searchController.text.trim().toLowerCase();

    return _orders.where((order) {
      // Tab filter
      if (_selectedFilterIndex == 1 &&
          order.status != AdminOrderStatus.baru) {
        return false;
      }
      if (_selectedFilterIndex == 2 &&
          order.status != AdminOrderStatus.diproses) {
        return false;
      }
      if (_selectedFilterIndex == 3 &&
          order.status != AdminOrderStatus.siapDiambil) {
        return false;
      }
      if (_selectedFilterIndex == 4 &&
          order.status != AdminOrderStatus.dalamPengiriman) {
        return false;
      }

      // Search query
      if (query.isNotEmpty) {
        final matchId = order.orderId.toLowerCase().contains(query);
        final matchCustomer = order.customerName.toLowerCase().contains(query);
        final matchPhone = order.customerPhone.toLowerCase().contains(query);
        return matchId || matchCustomer || matchPhone;
      }
      return true;
    }).toList();
  }

  void _handleContextualAction(AdminOrderDetail order) {
    switch (order.status) {
      case AdminOrderStatus.baru:
        _updateOrderStatus(order.orderId, AdminOrderStatus.diproses);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #${order.orderId} diproses oleh kasir'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case AdminOrderStatus.diproses:
        _updateOrderStatus(order.orderId, AdminOrderStatus.siapDiambil);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #${order.orderId} siap diambil di toko!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case AdminOrderStatus.siapDiambil:
        _showQrScanPickupDialog(order);
        break;

      case AdminOrderStatus.dalamPengiriman:
        _showCourierTrackingDialog(order);
        break;

      case AdminOrderStatus.selesai:
      case AdminOrderStatus.dibatalkan:
        _showDetailModal(order);
        break;
    }
  }

  void _updateOrderStatus(String orderId, AdminOrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }
    });
  }

  Future<void> _navigateToDetail(AdminOrderDetail order) async {
    final updated = await Navigator.push<AdminOrderDetail>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminOrderDetailScreen(order: order),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        final index = _orders.indexWhere((o) => o.orderId == updated.orderId);
        if (index != -1) {
          _orders[index] = updated;
        }
      });
    }
  }

  void _showQrScanPickupDialog(AdminOrderDetail order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.success,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Validasi Penyerahan Buku',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pesanan #${order.orderId} • ${order.customerName}',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (order.pickupCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kode Pickup: ${order.pickupCode}',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _updateOrderStatus(order.orderId, AdminOrderStatus.selesai);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Buku #${order.orderId} telah diserahkan & status pesanan Selesai!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Konfirmasi Serah Terima Buku'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourierTrackingDialog(AdminOrderDetail order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Lacak Pengantaran Kurir',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #${order.orderId}',
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Alamat Tujuan:',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              order.address ?? 'Alamat toko',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_bike_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kurir Toko Budi (Pak Joko) sedang dalam perjalanan mengantar buku.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _updateOrderStatus(order.orderId, AdminOrderStatus.selesai);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pesanan #${order.orderId} ditandai Terkirim & Selesai!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Tandai Telah Diterima'),
          ),
        ],
      ),
    );
  }

  void _showDetailModal(AdminOrderDetail order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Pesanan #${order.orderId}',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 17,
                      ),
                    ),
                    OrderStatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.outlineVariant),
                const SizedBox(height: 12),

                // Customer info
                Text(
                  'Data Pembeli',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Nama: ${order.customerName}'),
                Text('Telepon: ${order.customerPhone}'),
                Text('Metode: ${order.deliveryType}'),
                Text('Pembayaran: ${order.paymentMethod}'),
                if (order.address != null) ...[
                  const SizedBox(height: 4),
                  Text('Alamat: ${order.address}'),
                ],
                const SizedBox(height: 14),

                // Items
                Text(
                  'Daftar Buku',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                ...order.books.map(
                  (b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${b.qty}x ${b.title}'),
                        Text('Rp ${b.price * b.qty}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: AppColors.outlineVariant),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Rp ${order.totalPrice}',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = _filteredOrders;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pesanan Masuk',
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Update: Baru saja',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$_totalNeedAction Perlu Aksi',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari ID pesanan (#ORD...), nama pembeli...',
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.outline,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Tabs (Semua, Baru, Diproses, Siap Diambil, Dikirim)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(0, 'Semua (${_orders.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        1,
                        'Baru ($_countBaru)',
                        highlightColor: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        2,
                        'Diproses ($_countDiproses)',
                        highlightColor: const Color(0xFF2E78B7),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        3,
                        'Siap Diambil ($_countSiapDiambil)',
                        highlightColor: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        4,
                        'Dikirim ($_countDikirim)',
                        highlightColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Order Cards List
                if (displayedList.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = displayedList[index];
                      return OrderCard(
                        order: order,
                        onDetailTap: () => _navigateToDetail(order),
                        onActionTap: () => _handleContextualAction(order),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Bottom Sticky Summary Bar
        OrderSummaryBar(
          completedToday: 28,
          cancelledToday: 1,
          onReportTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mengunduh Laporan Pesanan Harian (PDF/Excel)...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label, {Color? highlightColor}) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (highlightColor ?? AppColors.primary)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (highlightColor ?? AppColors.onSurfaceVariant),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada pesanan yang sesuai',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Semua pesanan pada filter ini telah diproses atau tidak ditemukan.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
