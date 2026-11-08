import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../cart/screens/cart_screen.dart';
import '../../category/screens/category_screen.dart';
import '../../home/home_screen.dart';
import '../../review/screens/write_review_screen.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../widgets/order_brand_story_card.dart';
import '../widgets/order_card_item.dart';
import '../widgets/order_filter_chips.dart';
import '../widgets/order_qr_pickup_modal.dart';
import '../../notification/screens/notification_screen.dart';
import '../../profile/screens/profile_screen.dart';
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
  List<OrderModel> _customerOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter;
    _loadCustomerOrders();
  }

  Future<void> _loadCustomerOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await OrderService.fetchCustomerOrders();
      if (mounted) {
        setState(() {
          _customerOrders = orders;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _customerOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  List<OrderModel> get _allOrders => _customerOrders;

  Map<OrderStatus, int> get _statusCounts {
    final counts = <OrderStatus, int>{
      OrderStatus.all: _allOrders.length,
      OrderStatus.processing: 0,
      OrderStatus.shipping: 0,
      OrderStatus.readyPickup: 0,
      OrderStatus.completed: 0,
      OrderStatus.cancelled: 0,
    };

    for (final order in _allOrders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }

    return counts;
  }

  List<OrderModel> get _filteredOrders {
    if (_selectedStatus == OrderStatus.all) {
      return _allOrders;
    }
    return _allOrders
        .where((order) => order.status == _selectedStatus)
        .toList();
  }

  Future<void> _handleBuyAgain(OrderModel order) async {
    final count = await OrderService.reAddItemsToCart(order.items);
    if (!mounted) return;

    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count buku telah dimasukkan kembali ke keranjang belanja!'),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Keranjang',
            textColor: AppColors.secondary,
            onPressed: () {
              AppNavigation.hideCurrentSnackBar();
              AppNavigation.push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buku tidak dapat ditambahkan ke keranjang saat ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleWriteReview(OrderModel order) {
    if (order.items.isEmpty) return;

    if (order.items.length == 1) {
      final item = order.items.first;
      _openWriteReviewScreen(item, order.id);
    } else {
      _showBookSelectionModal(order);
    }
  }

  void _openWriteReviewScreen(OrderItemModel item, String orderId) async {
    final bookId = item.bookId ?? '';
    if (bookId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informasi buku tidak lengkap untuk menulis ulasan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          bookId: bookId,
          bookTitle: item.title,
          bookAuthor: item.author,
          bookCoverUrl: item.coverUrl,
          orderId: orderId,
        ),
      ),
    );

    if (result == true) {
      _loadCustomerOrders();
    }
  }

  void _showBookSelectionModal(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Pilih Buku untuk Diulas',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pesanan ${order.id} berisi ${order.items.length} buku. Pilih buku yang ingin Anda beri penilaian:',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (ctx, idx) {
                  final item = order.items[idx];
                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 60,
                          color: AppColors.surfaceContainerHigh,
                          child: item.coverUrl.isNotEmpty
                              ? Image.network(
                                  item.coverUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.menu_book_rounded,
                                    size: 20,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : const Icon(
                                  Icons.menu_book_rounded,
                                  size: 20,
                                  color: AppColors.secondary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.author,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Subtotal: ${item.subtotal}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openWriteReviewScreen(item, order.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Ulas'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;
    final readyCount = _statusCounts[OrderStatus.readyPickup] ?? 0;

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
      bottomNavigationBar: BookstoreBottomNav(
        currentIndex: 3,
        onTabSelected: _onBottomNavSelected,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadCustomerOrders,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // 1. Subheader: Receipt Icon + Title + Status Badge + Description
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
                                  decoration: BoxDecoration(
                                    color: readyCount > 0
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  readyCount > 0
                                      ? '$readyCount Perlu Diambil'
                                      : '${_customerOrders.length} Pesanan Real',
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
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (filteredOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
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
                          _selectedStatus == OrderStatus.all
                              ? 'Anda belum memiliki riwayat pesanan.'
                              : 'Tidak ditemukan pesanan pada filter ${_selectedStatus.label}.',
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
                        onViewDetail: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order: order),
                            ),
                          );
                          _loadCustomerOrders();
                        },
                        onBuyAgain: () => _handleBuyAgain(order),
                        onWriteReview: () => _handleWriteReview(order),
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
      ),
    );
  }
}
