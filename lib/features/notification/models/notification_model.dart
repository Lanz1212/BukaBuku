import 'package:flutter/material.dart';

enum NotificationCategory {
  all,
  order,
  promo,
}

enum NotificationType {
  orderPickupReady,
  orderShipping,
  paymentSuccess,
  orderProcessing,
  orderCompleted,
  promoVoucher,
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final NotificationType type;
  final bool isUnread;
  final DateTime createdAt;
  final String? orderId;
  final String? refId;
  final String? storeName;
  final String? deliveryEta;
  final String? voucherCode;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.type,
    this.isUnread = true,
    required this.createdAt,
    this.orderId,
    this.refId,
    this.storeName,
    this.deliveryEta,
    this.voucherCode,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.orderPickupReady:
        return Icons.storefront_outlined;
      case NotificationType.orderShipping:
        return Icons.local_shipping_outlined;
      case NotificationType.paymentSuccess:
        return Icons.check_circle_outline;
      case NotificationType.orderProcessing:
        return Icons.auto_stories_outlined;
      case NotificationType.orderCompleted:
        return Icons.task_alt_outlined;
      case NotificationType.promoVoucher:
        return Icons.loyalty_outlined;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
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
      return '${createdAt.day} $month ${createdAt.year}';
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    NotificationType? type,
    bool? isUnread,
    DateTime? createdAt,
    String? orderId,
    String? refId,
    String? storeName,
    String? deliveryEta,
    String? voucherCode,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
      orderId: orderId ?? this.orderId,
      refId: refId ?? this.refId,
      storeName: storeName ?? this.storeName,
      deliveryEta: deliveryEta ?? this.deliveryEta,
      voucherCode: voucherCode ?? this.voucherCode,
    );
  }

  factory NotificationModel.fromSupabase(Map<String, dynamic> data) {
    final categoryStr = (data['category'] as String?)?.toLowerCase() ?? 'order';
    final category = categoryStr == 'promo'
        ? NotificationCategory.promo
        : NotificationCategory.order;

    final typeStr = data['type'] as String? ?? 'orderProcessing';
    NotificationType type = NotificationType.orderProcessing;
    switch (typeStr) {
      case 'orderPickupReady':
        type = NotificationType.orderPickupReady;
        break;
      case 'orderShipping':
        type = NotificationType.orderShipping;
        break;
      case 'paymentSuccess':
        type = NotificationType.paymentSuccess;
        break;
      case 'orderCompleted':
        type = NotificationType.orderCompleted;
        break;
      case 'promoVoucher':
        type = NotificationType.promoVoucher;
        break;
      case 'orderProcessing':
      default:
        type = NotificationType.orderProcessing;
        break;
    }

    final createdAtStr = data['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now())
        : DateTime.now();

    return NotificationModel(
      id: data['id']?.toString() ?? '',
      title: data['title'] as String? ?? 'Pemberitahuan',
      body: data['body'] as String? ?? '',
      category: category,
      type: type,
      isUnread: data['is_unread'] as bool? ?? true,
      createdAt: createdAt,
      orderId: data['order_id'] != null ? '#${data['order_id']}' : null,
      refId: data['ref_id'] as String?,
      storeName: data['store_name'] as String?,
      deliveryEta: data['delivery_eta'] as String?,
      voucherCode: data['voucher_code'] as String?,
    );
  }
}
