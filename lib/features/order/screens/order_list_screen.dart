import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../cart/screens/cart_screen.dart';
import '../../category/screens/category_screen.dart';
import '../../home/home_screen.dart';
import '../models/order_model.dart';
import '../widgets/order_brand_story_card.dart';
import '../widgets/order_card_item.dart';
import '../widgets/order_filter_chips.dart';
import '../widgets/order_qr_pickup_modal.dart';
import '../../notification/screens/notification_screen.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  final OrderStatus initialFilter;

  const OrderListScreen({
    super.key,
    this.initialFilter = OrderStatus.all,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late OrderStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter;
  }

  Map<OrderStatus, int> get _statusCounts {
    final counts = <OrderStatus, int>{
      OrderStatus.all: mockOrders.length,
      OrderStatus.processing: 0,
      OrderStatus.shipping: 0,
      OrderStatus.readyPickup: 0,
      OrderStatus.completed: 0,
    };

    for (final order in mockOrders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }

    return counts;
  }

  List<OrderModel> get _filteredOrders {
    if (_selectedStatus == OrderStatus.all) {
      return mockOrders;
    }
    return mockOrders
        .where((order) => order.status == _selectedStatus)
        .toList();
  }

  void _onBottomNavSelected(int index) {
    if (index == 3) return; // Currently on Orders

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } else if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Halaman profil segera hadir!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Pesanan Saya',
        showNotificationButton: true,
        onNotificationPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            ),
          );
        },
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
      bottomNavigationBar: BookstoreBottomNav(
        currentIndex: 3,
        onTabSelected: _onBottomNavSelected,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              // 1. Subheader: Receipt Icon + Title + Pulse Badge + Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              size: 24,
                              color: AppColors.primaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Pesanan Saya',
                              style: AppTypography.headlineMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
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
                            color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '1 Perlu Diambil',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Lacak status buku pesanan, kode pickup, dan riwayat belanja Anda.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Filter Tabs
              OrderFilterChips(
                selectedStatus: _selectedStatus,
                statusCounts: _statusCounts,
                onFilterChanged: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
              ),

              const SizedBox(height: 14),

              // 3. Order List Cards
              if (filteredOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_rounded,
                          size: 32,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Belum Ada Pesanan',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tidak ditemukan pesanan pada filter ${_selectedStatus.label}.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return OrderCardItem(
                      order: order,
                      onShowQr: () => OrderQrPickupModal.show(context, order),
                      onViewDetail: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 20),

              // 4. Sentuhan Kasih Toko Buku Budi Footer Card
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: OrderBrandStoryCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
