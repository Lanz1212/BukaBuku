import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/book_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/cashier_log_service.dart';
import '../../order_management/models/admin_order_detail.dart';
import '../../order_management/screens/admin_order_detail_screen.dart';
import '../models/admin_stat_item.dart';
import '../models/admin_order_item.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_quick_actions.dart';
import '../widgets/admin_recent_orders.dart';
import '../widgets/admin_low_stock_section.dart';
import '../widgets/admin_sales_chart.dart';
import '../../book_management/screens/add_book_screen.dart';
import '../../payment_management/screens/payment_management_screen.dart';
import '../../scan_qr_pickup/screens/scan_qr_pickup_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToBooks;
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToStock;
  final void Function(String bookId)? onNavigateToStockWithBook;

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToBooks,
    this.onNavigateToOrders,
    this.onNavigateToStock,
    this.onNavigateToStockWithBook,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<AdminStatItem> _stats = AdminStatItem.mockStats;
  List<AdminRecentOrder> _orders = [];
  List<AdminLowStockItem> _lowStock = [];
  int _totalOrdersCount = 0;
  String _adminName = 'Admin';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  String get _currentDateFormatted {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return 'Hari ini, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _loadDashboardData() async {
    try {
      final adminName = await CashierLogService.getCurrentAdminName();
      final summary = await BookService.fetchStockSummary();
      final lowBooks = await BookService.fetchLowStockBooks(limit: 5);
      final realOrders = await OrderService.fetchAdminOrders(limit: 50);

      if (mounted) {
        setState(() {
          _adminName = adminName;
          _totalOrdersCount = realOrders.length;

          // 1. Update stats with real data
          final totalTitles = summary['totalTitles'] ?? 0;
          final totalCopies = summary['totalCopies'] ?? 0;
          final newOrdersCount = realOrders
              .where((o) => o.status == AdminOrderStatus.baru)
              .length;
          final totalSales = realOrders
              .where((o) => o.isPaid)
              .fold(0, (sum, o) => sum + o.totalPrice);

          final formattedSales = 'Rp${totalSales.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

          _stats = [
            AdminStatItem(
              title: 'Total Buku',
              value: '$totalTitles',
              unit: 'judul',
              subtitle: '$totalCopies total eksemplar',
              icon: Icons.menu_book_outlined,
            ),
            AdminStatItem(
              title: 'Total Pesanan',
              value: '${realOrders.length}',
              unit: 'pesanan',
              subtitle: 'Tersinkron Supabase',
              icon: Icons.shopping_bag_outlined,
            ),
            AdminStatItem(
              title: 'Pesanan Baru',
              value: '$newOrdersCount',
              unit: 'pesanan',
              subtitle: 'Prioritas pemrosesan',
              icon: Icons.pending_actions_rounded,
              isHighlight: newOrdersCount > 0,
              badgeText: newOrdersCount > 0 ? 'Perlu Proses' : null,
            ),
            AdminStatItem(
              title: 'Total Transaksi',
              value: formattedSales,
              unit: '',
              subtitle: 'Lunas terverifikasi',
              icon: Icons.trending_up_rounded,
            ),
          ];

          // 2. Update recent orders (limit to 5 for recent widget)
          _orders = realOrders.take(5).map((o) {
            final isDelivery = o.deliveryType.toLowerCase().contains('kurir') ||
                o.deliveryType.toLowerCase().contains('delivery');
            return AdminRecentOrder(
              orderId: '#${o.orderId}',
              rawOrderId: o.orderId,
              customerName: o.customerName,
              itemCount: o.books.fold(0, (sum, b) => sum + b.qty),
              totalPrice: o.totalPrice,
              deliveryType: isDelivery ? 'Antar ke Rumah' : 'Ambil di Toko',
              deliveryIcon: isDelivery
                  ? Icons.local_shipping_outlined
                  : Icons.store_rounded,
              status: o.statusLabel,
              isNew: o.status == AdminOrderStatus.baru,
            );
          }).toList();

          // 3. Update low stock items
          _lowStock = lowBooks.map((b) => AdminLowStockItem(
            bookId: b.id,
            title: b.title,
            author: b.author,
            stockLeft: b.stock,
            rackLocation: b.rackLocation,
            coverUrl: b.coverUrl,
          )).toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading admin dashboard data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToOrderDetail(String rawOrderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final order = await OrderService.fetchOrderById(rawOrderId);
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (order != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminOrderDetailScreen(order: order),
          ),
        );
        _loadDashboardData();
      } else if (mounted) {
        _showNotice('Pesanan #$rawOrderId tidak ditemukan di database');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showNotice('Gagal memuat detail pesanan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading) ...[
              const LinearProgressIndicator(
                minHeight: 2.5,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
              const SizedBox(height: 12),
            ],
            // Greeting & Status Header
            _buildGreetingHeader(),
            const SizedBox(height: 18),

            // 2x2 Statistics Grid
            _buildStatsGrid(),
            const SizedBox(height: 22),

            // Aksi Cepat Admin
            AdminQuickActions(
              onScanQr: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScanQrPickupScreen(),
                  ),
                );
              },
              onPayment: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentManagementScreen(),
                  ),
                );
              },
              onAddBook: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookScreen(),
                  ),
                ).then((_) => _loadDashboardData());
              },
              onManageStock: widget.onNavigateToStock ??
                  widget.onNavigateToBooks ??
                  () => _showNotice('Buka kelola stok'),
            ),
            const SizedBox(height: 22),

            // Pesanan Terbaru (Real data from database)
            AdminRecentOrders(
              orders: _orders,
              totalCount: _totalOrdersCount,
              onViewAll: widget.onNavigateToOrders ??
                  () => _showNotice('Membuka seluruh daftar pesanan'),
              onOrderAction: (order) {
                _navigateToOrderDetail(order.rawOrderId);
              },
            ),
            const SizedBox(height: 22),

            // Stok Menipis (Inventory Warning from database)
            AdminLowStockSection(
              lowStockItems: _lowStock,
              onManageStock: widget.onNavigateToStock ??
                  widget.onNavigateToBooks ??
                  () => _showNotice('Membuka inventaris stok'),
              onAddStock: (item) {
                if (widget.onNavigateToStockWithBook != null) {
                  widget.onNavigateToStockWithBook!(item.bookId);
                } else if (widget.onNavigateToStock != null) {
                  widget.onNavigateToStock!();
                } else {
                  _showNotice('Membuka stok untuk "${item.title}"');
                }
              },
            ),
            const SizedBox(height: 22),

            // Grafik Penjualan Bulanan Real
            const AdminSalesChart(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang, $_adminName 👋',
                style: AppTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Staff & Kasir Toko',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.outlineVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentDateFormatted,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_cafe_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                item: _stats[0],
                onTap: widget.onNavigateToBooks,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AdminStatCard(
                item: _stats[1],
                onTap: widget.onNavigateToOrders,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                item: _stats[2],
                onTap: widget.onNavigateToOrders,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AdminStatCard(
                item: _stats[3],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentManagementScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
