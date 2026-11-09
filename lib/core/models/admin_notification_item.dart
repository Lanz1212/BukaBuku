import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AdminNotifCategory {
  all,
  order,
  stock,
  inventory,
}

class AdminNotificationItem {
  final String id;
  final String title;
  final String body;
  final AdminNotifCategory category;
  final String type;
  final bool isUnread;
  final DateTime createdAt;
  final String? orderId;
  final String? refId;
  final String? userId;

  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
    this.isUnread = true,
    required this.createdAt,
    this.orderId,
    this.refId,
    this.userId,
  });

  AdminNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    AdminNotifCategory? category,
    String? type,
    bool? isUnread,
    DateTime? createdAt,
    String? orderId,
    String? refId,
    String? userId,
  }) {
    return AdminNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      refId: refId ?? this.refId,
      userId: userId ?? this.userId,
    );
  }

  IconData get icon {
    switch (type) {
      case 'newOrder':
        return Icons.shopping_bag_outlined;
      case 'orderPaid':
        return Icons.payments_outlined;
      case 'qrScanSuccess':
        return Icons.qr_code_scanner_rounded;
      case 'orderCompleted':
        return Icons.verified_outlined;
      case 'lowStock':
        return Icons.warning_amber_rounded;
      case 'outOfStock':
        return Icons.error_outline_rounded;
      case 'stockAdjusted':
        return Icons.inventory_2_outlined;
      case 'bookAdded':
        return Icons.auto_stories_outlined;
      case 'bookUpdated':
        return Icons.edit_note_rounded;
      case 'categoryAdded':
        return Icons.category_outlined;
      case 'categoryUpdated':
        return Icons.folder_open_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'newOrder':
        return AppColors.primary;
      case 'orderPaid':
      case 'qrScanSuccess':
      case 'orderCompleted':
        return AppColors.success;
      case 'lowStock':
        return AppColors.warning;
      case 'outOfStock':
        return AppColors.error;
      case 'stockAdjusted':
      case 'categoryAdded':
      case 'categoryUpdated':
        return AppColors.secondary;
      case 'bookAdded':
      case 'bookUpdated':
        return const Color(0xFF2C5E7A);
      default:
        return AppColors.primary;
    }
  }

  Color get iconContainerColor {
    return iconColor.withValues(alpha: 0.12);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 45) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final month = months[(createdAt.month - 1).clamp(0, 11)];
      final hour = createdAt.hour.toString().padLeft(2, '0');
      final minute = createdAt.minute.toString().padLeft(2, '0');
      return '${createdAt.day} $month ${createdAt.year}, $hour:$minute WIB';
    }
  }

  factory AdminNotificationItem.fromMap(Map<String, dynamic> data) {
    final categoryStr = (data['category'] as String?)?.toLowerCase() ?? 'order';
    AdminNotifCategory category = AdminNotifCategory.order;
    if (categoryStr == 'stock') {
      category = AdminNotifCategory.stock;
    } else if (categoryStr == 'inventory' || categoryStr == 'buku' || categoryStr == 'kategori') {
      category = AdminNotifCategory.inventory;
    }

    final createdAtStr = data['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now())
        : DateTime.now();

    return AdminNotificationItem(
      id: data['id']?.toString() ?? '',
      title: data['title'] as String? ?? 'Pemberitahuan Admin',
      body: data['body'] as String? ?? '',
      category: category,
      type: data['type'] as String? ?? 'system',
      isUnread: data['is_unread'] as bool? ?? true,
      createdAt: createdAt,
      orderId: data['order_id']?.toString(),
      refId: data['ref_id']?.toString(),
      userId: data['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    String catStr = 'order';
    if (category == AdminNotifCategory.stock) {
      catStr = 'stock';
    } else if (category == AdminNotifCategory.inventory) {
      catStr = 'inventory';
    }

    return {
      'target_role': 'admin',
      'user_id': userId,
      'title': title,
      'body': body,
      'category': catStr,
      'type': type,
      'is_unread': isUnread,
      'order_id': orderId,
      'ref_id': refId,
    };
  }
}

