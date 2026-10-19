import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../order/screens/pickup_success_screen.dart';
import '../../order/screens/qr_pickup_screen.dart';
import '../models/notification_model.dart';
import '../widgets/notification_filter_tabs.dart';
import '../widgets/notification_item.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationModel> _notifications;
  NotificationCategory _selectedCategory = NotificationCategory.all;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(mockNotifications);
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  void _markAllAsRead() {
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
      ),
    );
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
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

            // Notification Items List
            if (filteredNotifications.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_off_outlined,
                        size: 48,
                        color: AppColors.outlineVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada notifikasi dalam kategori ini',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
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
                          onOpenQrPickup: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrPickupScreen(),
                              ),
                            );
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
    );
  }
}
