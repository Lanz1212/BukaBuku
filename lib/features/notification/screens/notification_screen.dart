import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/order_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../order/screens/order_detail_screen.dart';
import '../../order/screens/pickup_success_screen.dart';
import '../../order/screens/qr_pickup_screen.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  NotificationCategory _selectedCategory = NotificationCategory.all;
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealtime();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtime() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _realtimeChannel = NotificationService.subscribeToNotifications(
        userId: user.id,
        onData: () {
          if (mounted) {
            _loadNotifications(silent: true);
          }
        },
      );
    }
  }

  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }
    final items = await NotificationService.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications
            .map((n) => n.copyWith(isUnread: false))
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sudah dibaca'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onItemTap(NotificationModel item) async {
    if (item.isUnread) {
      await NotificationService.markAsRead(item.id);
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == item.id);
          if (index != -1) {
            _notifications[index] = item.copyWith(isUnread: false);
          }
        });
      }
    }

    if (!mounted) return;

    if (item.orderId != null) {
      final cleanId = item.orderId!.replaceAll('#', '').trim();
      final order = await OrderService.fetchOrderByIdForUser(cleanId);
      if (order != null && mounted) {
        if (item.type == NotificationType.orderPickupReady) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QrPickupScreen(order: order),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(order: order),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _notifications.where((n) {
      if (_selectedCategory == NotificationCategory.all) return true;
      return n.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Notifikasi',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadNotifications(silent: false),
          color: AppColors.primaryContainer,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header Row: "Notifikasi" title + unread badge + "Tandai Semua Dibaca"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Notifikasi',
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _unreadCount > 0
                                  ? AppColors.secondaryContainer
                                  : AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              _unreadCount > 0
                                  ? '$_unreadCount Baru'
                                  : 'Semua Dibaca',
                              style: AppTypography.caption.copyWith(
                                color: _unreadCount > 0
                                    ? AppColors.onSecondaryContainer
                                    : AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _unreadCount > 0 ? _markAllAsRead : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.done_all,
                                size: 16,
                                color: _unreadCount > 0
                                    ? AppColors.secondary
                                    : AppColors.outlineVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tandai Semua Dibaca',
                                style: AppTypography.caption.copyWith(
                                  color: _unreadCount > 0
                                      ? AppColors.secondary
                                      : AppColors.outlineVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal Filter Chips
              SliverToBoxAdapter(
                child: NotificationFilterTabs(
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                )
              // Notification Items List or Empty State
              else if (filteredNotifications.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 48,
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == NotificationCategory.all
                                ? 'Belum Ada Notifikasi'
                                : 'Tidak ada notifikasi dalam kategori ini',
                            textAlign: TextAlign.center,
                            style: AppTypography.titleMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pemberitahuan status pesanan dan penawaran buku terbaru akan muncul di sini secara real-time.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredNotifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NotificationItem(
                            notification: item,
                            onTap: () => _onItemTap(item),
                            onOpenQrPickup: () async {
                              final nav = Navigator.of(context);
                              if (item.orderId != null) {
                                final cleanId = item.orderId!.replaceAll('#', '').trim();
                                final order = await OrderService.fetchOrderByIdForUser(cleanId);
                                if (order != null && mounted) {
                                  nav.push(
                                    MaterialPageRoute(
                                      builder: (_) => QrPickupScreen(order: order),
                                    ),
                                  );
                                  return;
                                }
                              }
                              if (mounted) {
                                nav.push(
                                  MaterialPageRoute(
                                    builder: (_) => const QrPickupScreen(),
                                  ),
                                );
                              }
                            },
                            onWriteReview: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PickupSuccessScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: filteredNotifications.length,
                    ),
                  ),
                ),

              // Bottom Archive Notice Footer
              if (!_isLoading && filteredNotifications.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.auto_stories,
                          size: 22,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kamu sudah membaca seluruh arsip pemberitahuan.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
