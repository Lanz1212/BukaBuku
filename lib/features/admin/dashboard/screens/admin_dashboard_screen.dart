import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/book_service.dart';
import '../../../../core/services/order_service.dart';
import '../../order_management/models/admin_order_detail.dart';
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

  const AdminDashboardScreen({
    super.key,
    this.onNavigateToBooks,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<AdminStatItem> _stats = AdminStatItem.mockStats;
  List<AdminRecentOrder> _orders = AdminRecentOrder.mockOrders;
  List<AdminLowStockItem> _lowStock = AdminLowStockItem.mockLowStock;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final summary = await BookService.fetchStockSummary();
      final lowBooks = await BookService.fetchLowStockBooks(limit: 5);
      final realOrders = await OrderService.fetchAdminOrders(limit: 10);

      if (mounted) {
        setState(() {
          final updatedStats = List<AdminStatItem>.from(_stats);
          if (updatedStats.isNotEmpty) {
            updatedStats[0] = AdminStatItem(
              title: 'Total Buku',
              value: '${summary['totalTitles'] ?? 0}',
              unit: 'judul',
              subtitle: '${summary['totalCopies'] ?? 0} total eksemplar',
              icon: Icons.menu_book_outlined,
            );
          }

          if (realOrders.isNotEmpty) {
            final newOrdersCount = realOrders
                .where((o) => o.status == AdminOrderStatus.baru)
                .length;
            final totalSales = realOrders
                .where((o) => o.isPaid)
                .fold(0, (sum, o) => sum + o.totalPrice);

            if (updatedStats.length > 2) {
              updatedStats[1] = AdminStatItem(
                title: 'Total Pesanan',
                value: '${realOrders.length}',
                unit: 'pesanan',
                subtitle: 'Tersinkron Supabase',
                icon: Icons.shopping_bag_outlined,
              );
              updatedStats[2] = AdminStatItem(
                title: 'Pesanan Baru',
                value: '$newOrdersCount',
                unit: 'pesanan',
                subtitle: 'Prioritas pemrosesan',
                icon: Icons.pending_actions_rounded,
                isHighlight: true,
                badgeText: 'Perlu Proses',
              );
            }

            if (updatedStats.length > 3) {
              final formattedSales = 'Rp${totalSales.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
              updatedStats[3] = AdminStatItem(
                title: 'Total Transaksi',
                value: formattedSales,
                unit: '',
                subtitle: 'Lunas terverifikasi',
                icon: Icons.trending_up_rounded,
              );
            }

            _orders = realOrders.map((o) {
              final isDelivery = o.deliveryType
                      .toLowerCase()
                      .contains('kurir') ||
                  o.deliveryType.toLowerCase().contains('delivery');
              return AdminRecentOrder(
                orderId: '#${o.orderId}',
                customerName: o.customerName,
                itemCount: o.books.fold(0, (sum, b) => sum + b.qty),
                totalPrice: o.totalPrice,
                deliveryType:
                    isDelivery ? 'Antar ke Rumah' : 'Ambil di Toko',
                deliveryIcon: isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.store_rounded,
                status: o.statusLabel,
                isNew: o.status == AdminOrderStatus.baru,
              );
            }).toList();
          }
          _stats = updatedStats;

          if (lowBooks.isNotEmpty) {
            _lowStock = lowBooks
                .map((b) => AdminLowStockItem(
                      title: b.title,
                      author: b.author,
                      stockLeft: b.stock,
                      rackLocation: b.rackLocation,
                      coverUrl: b.coverUrl,
                    ))
                .toList();
          }
        });
      }
    } catch (_) {}
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              );
            },
            onManageStock: widget.onNavigateToBooks ??
                () => _showNotice('Buka kelola stok'),
          ),
          const SizedBox(height: 22),

          // Pesanan Terbaru
          AdminRecentOrders(
            orders: _orders,
            onViewAll: () => _showNotice('Membuka seluruh daftar pesanan toko (12)'),
            onOrderAction: (order) {
              if (order.isNew) {
                _showNotice('Pesanan ${order.orderId} diproses');
              } else {
                _showNotice('Detail pesanan ${order.orderId}');
              }
            },
          ),
          const SizedBox(height: 22),

          // Stok Menipis (Inventory Warning)
          AdminLowStockSection(
            lowStockItems: _lowStock,
            onManageStock: widget.onNavigateToBooks ??
                () => _showNotice('Membuka inventaris stok'),
            onAddStock: (item) {
              _showNotice('Permintaan restock "${item.title}" dicatat (+5 eks)');
            },
          ),
          const SizedBox(height: 22),

          // Grafik Penjualan Mingguan
          const AdminSalesChart(),
          const SizedBox(height: 24),
        ],
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
                'Selamat datang, Budi 👋',
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
                      'Owner & Admin Utama',
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
                    'Hari ini, 12 Mei 2024',
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
                onTap: () => _showNotice('Buka daftar pesanan hari ini'),
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
                onTap: () => _showNotice('5 pesanan baru perlu diproses'),
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
