import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/order_service.dart';
import '../models/admin_order_detail.dart';
import '../widgets/order_card.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_summary_bar.dart';
import 'admin_order_detail_screen.dart';
import '../../scan_qr_pickup/screens/scan_qr_pickup_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  List<AdminOrderDetail> _orders = [];
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: Semua, 1: Baru, 2: Diproses, 3: Siap Diambil, 4: Dikirim

  @override
  void initState() {
    super.initState();
    _orders = [];
    _loadOrders();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await OrderService.fetchAdminOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading admin orders from Supabase: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = OrderService.subscribeToOrders(
      onData: () {
        debugPrint('Supabase Realtime event: reload admin orders');
        _loadOrders();
      },
    );
  }

  int get _countBaru =>
      _orders.where((o) => o.status == AdminOrderStatus.baru).length;

  int get _countDiproses =>
      _orders.where((o) => o.status == AdminOrderStatus.diproses).length;

  int get _countSiapDiambil =>
      _orders.where((o) => o.status == AdminOrderStatus.siapDiambil).length;

  int get _countSiapDikirim =>
      _orders.where((o) => o.status == AdminOrderStatus.siapDikirim).length;

  int get _countDikirim =>
      _orders.where((o) => o.status == AdminOrderStatus.dalamPengiriman).length;

  int get _totalNeedAction =>
      _countBaru + _countDiproses + _countSiapDiambil + _countSiapDikirim;

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
          order.status != AdminOrderStatus.siapDikirim) {
        return false;
      }
      if (_selectedFilterIndex == 5 &&
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
    final isDelivery = order.deliveryType.toLowerCase().contains('kurir');

    switch (order.status) {
      case AdminOrderStatus.baru:
        _updateOrderStatus(order.orderId, AdminOrderStatus.diproses);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #${order.orderId} diproses oleh kasir/admin'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;

      case AdminOrderStatus.diproses:
        if (isDelivery) {
          _updateOrderStatus(order.orderId, AdminOrderStatus.siapDikirim);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pesanan #${order.orderId} telah selesai disiapkan & siap diserahkan ke kurir toko!'),
              backgroundColor: const Color(0xFF8E44AD),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          _updateOrderStatus(order.orderId, AdminOrderStatus.siapDiambil);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pesanan #${order.orderId} siap diambil di toko!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;

      case AdminOrderStatus.siapDikirim:
        _showHandoverToCourierDialog(order);
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

  Future<void> _updateOrderStatus(
      String orderId, AdminOrderStatus newStatus) async {
    setState(() {
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }
    });

    try {
      await OrderService.updateOrderStatus(orderId, newStatus);
    } catch (e) {
      debugPrint('Error updating order status in Supabase: $e');
      _loadOrders();
    }
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
    _loadOrders();
  }

  void _showQrScanPickupDialog(AdminOrderDetail order) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => ScanQrPickupScreen(
          preloadedOrder: order,
        ),
      ),
    );

    if (result is AdminOrderDetail) {
      _updateOrderStatus(order.orderId, result.status);
    } else if (result == true) {
      _updateOrderStatus(order.orderId, AdminOrderStatus.selesai);
    }
  }

  void _showHandoverToCourierDialog(AdminOrderDetail order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.two_wheeler_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Serahkan ke Kurir',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
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
            Text('Nama Pembeli: ${order.customerName}',
                style: const TextStyle(fontSize: 13)),
            Text('No. Telepon: ${order.customerPhone}',
                style: const TextStyle(fontSize: 13)),
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
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan paket buku sudah rapi. Setelah diserahkan, kurir toko akan mengantar ke alamat dan pembeli dapat memantau status pesanan.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6B655F),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await OrderService.markHandedOverToCourier(order.orderId);
              _loadOrders();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Paket #${order.orderId} telah diserahkan ke kurir toko & sedang dalam perjalanan!',
                    ),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.two_wheeler_rounded, size: 18),
            label: const Text('Serahkan ke Kurir'),
          ),
        ],
      ),
    );
  }

  void _showCourierTrackingDialog(AdminOrderDetail order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.two_wheeler_rounded,
              color: AppColors.secondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Status Kurir Toko',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
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
                      'Kurir toko sedang dalam perjalanan ke alamat pembeli. Menunggu pembeli menekan tombol "Pesanan Sudah Sampai" di aplikasinya.',
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
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
            child: const Text('Bantu Tandai Selesai'),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final displayedList = _filteredOrders;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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

                // Filter Tabs (Semua, Baru, Diproses, Siap Diambil, Siap Dikirim, Dikirim)
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
                        'Siap Dikirim ($_countSiapDikirim)',
                        highlightColor: const Color(0xFF8E44AD),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        5,
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
