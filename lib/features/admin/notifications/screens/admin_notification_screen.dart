import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/admin_notification_item.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../order_management/screens/admin_order_detail_screen.dart';
import '../widgets/admin_notification_card.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  AdminNotifCategory _selectedCategory = AdminNotifCategory.all;
  List<AdminNotificationItem> _notifications = [];
  bool _isLoading = true;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _realtimeChannel = AdminNotificationService.subscribeToAdminNotifications(
      onData: () {
        if (mounted) {
          _loadNotifications(showLoading: false);
        }
      },
    );
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadNotifications({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }

    try {
      final list = await AdminNotificationService.fetchAdminNotifications(
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    if (unreadCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi sudah dibaca'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    await AdminNotificationService.markAllAsRead();
    if (!mounted) return;

    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isUnread: false)).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sudah dibaca'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleNotificationTap(AdminNotificationItem item) async {
    // 1. Tandai dibaca di database dan lokal jika masih unread
    if (item.isUnread) {
      await AdminNotificationService.markAsRead(item.id);
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == item.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isUnread: false);
          }
        });
      }
    }

    // 2. Jika ada order_id, buka detail pesanan
    final orderId = item.orderId;
    if (orderId != null && orderId.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text('Membuka pesanan #$orderId...'),
            ],
          ),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final fullOrder = await OrderService.fetchOrderById(orderId);
      if (fullOrder != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminOrderDetailScreen(order: fullOrder),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan #$orderId tidak ditemukan di database.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteNotification(AdminNotificationItem item) async {
    final deletedId = item.id;
    setState(() {
      _notifications.removeWhere((n) => n.id == deletedId);
    });

    await AdminNotificationService.deleteNotification(deletedId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifikasi telah dihapus'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'TUTUP',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifikasi Admin',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontSize: 18,
              ),
            ),
            Text(
              unreadCount > 0
                  ? '$unreadCount belum dibaca'
                  : 'Semua pesan terbaca',
              style: AppTypography.caption.copyWith(
                color: unreadCount > 0
                    ? AppColors.secondary
                    : AppColors.outline,
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _handleMarkAllAsRead,
            icon: const Icon(
              Icons.done_all_rounded,
              size: 17,
              color: AppColors.primary,
            ),
            label: Text(
              'Tandai Baca',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEFECE6)),

          // List or Empty View
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () => _loadNotifications(showLoading: false),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            return AdminNotificationCard(
                              item: notif,
                              onTap: () => _handleNotificationTap(notif),
                              onDelete: () => _handleDeleteNotification(notif),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'category': AdminNotifCategory.all, 'label': 'Semua'},
      {'category': AdminNotifCategory.order, 'label': 'Pesanan'},
      {'category': AdminNotifCategory.stock, 'label': 'Stok'},
      {'category': AdminNotifCategory.inventory, 'label': 'Katalog'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((t) {
            final cat = t['category'] as AdminNotifCategory;
            final label = t['label'] as String;
            final isSelected = _selectedCategory == cat;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(label),
                labelStyle: AppTypography.caption.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
                backgroundColor: AppColors.surfaceContainerLow,
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.onPrimary,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  _loadNotifications();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 38,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Belum Ada Notifikasi',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua aktivitas penting toko—seperti pesanan baru, stok menipis, verifikasi QR pickup, dan penambahan buku—akan langsung muncul di sini.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => _loadNotifications(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Segarkan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

