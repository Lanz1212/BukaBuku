import 'package:flutter/material.dart';

class AdminRecentOrder {
  final String orderId;
  final String customerName;
  final int itemCount;
  final int totalPrice;
  final String deliveryType;
  final IconData deliveryIcon;
  final String status;
  final bool isNew;

  const AdminRecentOrder({
    required this.orderId,
    required this.customerName,
    required this.itemCount,
    required this.totalPrice,
    required this.deliveryType,
    required this.deliveryIcon,
    required this.status,
    required this.isNew,
  });

  static List<AdminRecentOrder> get mockOrders => const [
        AdminRecentOrder(
          orderId: '#ORD00125',
          customerName: 'Budi Santoso',
          itemCount: 2,
          totalPrice: 181000,
          deliveryType: 'Ambil di Toko',
          deliveryIcon: Icons.store_rounded,
          status: 'Siap Diambil',
          isNew: false,
        ),
        AdminRecentOrder(
          orderId: '#ORD00126',
          customerName: 'Siti Rahma',
          itemCount: 1,
          totalPrice: 85000,
          deliveryType: 'Antar ke Rumah',
          deliveryIcon: Icons.local_shipping_outlined,
          status: 'Pesanan Baru',
          isNew: true,
        ),
      ];
}

class AdminLowStockItem {
  final String title;
  final String author;
  final int stockLeft;
  final String rackLocation;
  final String coverUrl;

  const AdminLowStockItem({
    required this.title,
    required this.author,
    required this.stockLeft,
    required this.rackLocation,
    required this.coverUrl,
  });

  static List<AdminLowStockItem> get mockLowStock => const [
        AdminLowStockItem(
          title: 'Atomic Habits',
          author: 'James Clear',
          stockLeft: 3,
          rackLocation: 'Rak A-04',
          coverUrl:
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
        ),
        AdminLowStockItem(
          title: 'Laut Bercerita',
          author: 'Leila S. Chudori',
          stockLeft: 2,
          rackLocation: 'Rak B-12',
          coverUrl:
              'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
        ),
      ];
}
