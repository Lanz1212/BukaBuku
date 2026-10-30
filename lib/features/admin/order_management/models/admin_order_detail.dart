import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum AdminOrderStatus {
  baru,
  diproses,
  siapDiambil,
  dalamPengiriman,
  selesai,
  dibatalkan,
}

class AdminOrderBookItem {
  final String title;
  final String author;
  final int qty;
  final int price;

  const AdminOrderBookItem({
    required this.title,
    required this.author,
    required this.qty,
    required this.price,
  });
}

class AdminOrderDetail {
  final String orderId;
  final String orderTime;
  final String customerName;
  final String customerPhone;
  final String deliveryType; // 'Ambil di Toko (Pickup)' | 'Kurir Toko (Delivery)'
  final String paymentMethod; // 'Transfer BCA • Lunas' | 'QRIS Toko • Lunas' | 'Bayar di Kasir'
  final bool isPaid;
  final AdminOrderStatus status;
  final List<AdminOrderBookItem> books;
  final int totalPrice;
  final String? specialNote;
  final String? address;
  final String? pickupCode;

  const AdminOrderDetail({
    required this.orderId,
    required this.orderTime,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryType,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
    required this.books,
    required this.totalPrice,
    this.specialNote,
    this.address,
    this.pickupCode,
  });

  AdminOrderDetail copyWith({
    String? orderId,
    String? orderTime,
    String? customerName,
    String? customerPhone,
    String? deliveryType,
    String? paymentMethod,
    bool? isPaid,
    AdminOrderStatus? status,
    List<AdminOrderBookItem>? books,
    int? totalPrice,
    String? specialNote,
    String? address,
    String? pickupCode,
  }) {
    return AdminOrderDetail(
      orderId: orderId ?? this.orderId,
      orderTime: orderTime ?? this.orderTime,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryType: deliveryType ?? this.deliveryType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      books: books ?? this.books,
      totalPrice: totalPrice ?? this.totalPrice,
      specialNote: specialNote ?? this.specialNote,
      address: address ?? this.address,
      pickupCode: pickupCode ?? this.pickupCode,
    );
  }

  String get statusLabel {
    switch (status) {
      case AdminOrderStatus.baru:
        return 'Pesanan Baru';
      case AdminOrderStatus.diproses:
        return 'Diproses';
      case AdminOrderStatus.siapDiambil:
        return 'Siap Diambil';
      case AdminOrderStatus.dalamPengiriman:
        return 'Dikirim';
      case AdminOrderStatus.selesai:
        return 'Selesai';
      case AdminOrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdminOrderStatus.baru:
        return AppColors.warning;
      case AdminOrderStatus.diproses:
        return const Color(0xFF2E78B7);
      case AdminOrderStatus.siapDiambil:
        return AppColors.success;
      case AdminOrderStatus.dalamPengiriman:
        return AppColors.secondary;
      case AdminOrderStatus.selesai:
        return AppColors.outline;
      case AdminOrderStatus.dibatalkan:
        return AppColors.error;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case AdminOrderStatus.baru:
        return AppColors.warning.withValues(alpha: 0.14);
      case AdminOrderStatus.diproses:
        return const Color(0xFF2E78B7).withValues(alpha: 0.12);
      case AdminOrderStatus.siapDiambil:
        return AppColors.success.withValues(alpha: 0.14);
      case AdminOrderStatus.dalamPengiriman:
        return AppColors.secondary.withValues(alpha: 0.14);
      case AdminOrderStatus.selesai:
        return AppColors.surfaceContainerHigh;
      case AdminOrderStatus.dibatalkan:
        return AppColors.error.withValues(alpha: 0.12);
    }
  }

  String get customerInitials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'BB';
  }

  static List<AdminOrderDetail> get mockOrders => [
        const AdminOrderDetail(
          orderId: 'ORD00125',
          orderTime: '10:45 WIB',
          customerName: 'Budi Santoso',
          customerPhone: '0812-3456-7890',
          deliveryType: 'Ambil di Toko (Pickup)',
          paymentMethod: 'Transfer BCA • Lunas',
          isPaid: true,
          status: AdminOrderStatus.siapDiambil,
          books: [
            AdminOrderBookItem(
              title: 'Atomic Habits',
              author: 'James Clear',
              qty: 1,
              price: 108000,
            ),
            AdminOrderBookItem(
              title: 'Filosofi Teras',
              author: 'Henry Manampiring',
              qty: 1,
              price: 98000,
            ),
          ],
          totalPrice: 206000,
          specialNote: 'Pelanggan minta dibungkus kado cokelat rapi',
          pickupCode: 'PU-125-982',
        ),
        const AdminOrderDetail(
          orderId: 'ORD00126',
          orderTime: '11:15 WIB',
          customerName: 'Siti Rahmawati',
          customerPhone: '0813-8899-2341',
          deliveryType: 'Kurir Toko (Delivery)',
          paymentMethod: 'Transfer Mandiri • Lunas',
          isPaid: true,
          status: AdminOrderStatus.baru,
          books: [
            AdminOrderBookItem(
              title: 'Laut Bercerita',
              author: 'Leila S. Chudori',
              qty: 2,
              price: 110000,
            ),
          ],
          totalPrice: 220000,
          address: 'Jl. Melati No. 14, RT 02/05, Kebayoran Baru, Jakarta Selatan',
          specialNote: 'Mohon hubungi sebelum kurir berangkat',
        ),
        const AdminOrderDetail(
          orderId: 'ORD00127',
          orderTime: '11:30 WIB',
          customerName: 'Ahmad Fauzi',
          customerPhone: '0857-1234-9087',
          deliveryType: 'Ambil di Toko (Pickup)',
          paymentMethod: 'Bayar di Kasir (Tunai)',
          isPaid: false,
          status: AdminOrderStatus.diproses,
          books: [
            AdminOrderBookItem(
              title: 'Psychology of Money',
              author: 'Morgan Housel',
              qty: 1,
              price: 95000,
            ),
            AdminOrderBookItem(
              title: 'Sapiens: Riwayat Singkat',
              author: 'Yuval Noah Harari',
              qty: 1,
              price: 135000,
            ),
          ],
          totalPrice: 230000,
          pickupCode: 'PU-127-114',
        ),
        const AdminOrderDetail(
          orderId: 'ORD00124',
          orderTime: '09:20 WIB',
          customerName: 'Dewi Lestari',
          customerPhone: '0878-9988-7766',
          deliveryType: 'Kurir Toko (Delivery)',
          paymentMethod: 'GoPay / QRIS • Lunas',
          isPaid: true,
          status: AdminOrderStatus.dalamPengiriman,
          books: [
            AdminOrderBookItem(
              title: 'Bumi Manusia',
              author: 'Pramoedya Ananta Toer',
              qty: 1,
              price: 125000,
            ),
          ],
          totalPrice: 125000,
          address: 'Apartemen Sudirman Park Tower B Lt. 12',
        ),
        const AdminOrderDetail(
          orderId: 'ORD00123',
          orderTime: '08:15 WIB',
          customerName: 'Reza Pratama',
          customerPhone: '0811-2233-4455',
          deliveryType: 'Ambil di Toko (Pickup)',
          paymentMethod: 'Transfer BCA • Lunas',
          isPaid: true,
          status: AdminOrderStatus.selesai,
          books: [
            AdminOrderBookItem(
              title: 'Clean Code',
              author: 'Robert C. Martin',
              qty: 1,
              price: 180000,
            ),
          ],
          totalPrice: 180000,
          pickupCode: 'PU-123-550',
        ),
      ];
}
