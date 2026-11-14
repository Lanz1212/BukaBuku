import 'package:flutter/material.dart';

class AdminRecentOrder {
  final String orderId;
  final String rawOrderId;
  final String customerName;
  final int itemCount;
  final int totalPrice;
  final String deliveryType;
  final IconData deliveryIcon;
  final String status;
  final bool isNew;

  const AdminRecentOrder({
    required this.orderId,
    required this.rawOrderId,
    required this.customerName,
    required this.itemCount,
    required this.totalPrice,
    required this.deliveryType,
    required this.deliveryIcon,
    required this.status,
    required this.isNew,
  });

  static List<AdminRecentOrder> get mockOrders => const [];
}

class AdminLowStockItem {
  final String bookId;
  final String title;
  final String author;
  final int stockLeft;
  final String rackLocation;
  final String coverUrl;

  const AdminLowStockItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.stockLeft,
    required this.rackLocation,
    required this.coverUrl,
  });

  static List<AdminLowStockItem> get mockLowStock => const [];
}
