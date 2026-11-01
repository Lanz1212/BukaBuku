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
  final String? rackLocation;
  final String? imageUrl;

  const AdminOrderBookItem({
    required this.title,
    required this.author,
    required this.qty,
    required this.price,
    this.rackLocation,
    this.imageUrl,
  });

  factory AdminOrderBookItem.fromMap(Map<String, dynamic> map) {
    return AdminOrderBookItem(
      title: map['title'] as String? ?? 'Buku',
      author: map['author'] as String? ?? 'Penulis',
      qty: (map['quantity'] as num?)?.toInt() ??
          (map['qty'] as num?)?.toInt() ??
          1,
      price: (map['price'] as num?)?.toInt() ?? 0,
      rackLocation: map['rack_location'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'quantity': qty,
      'price': price,
      'rack_location': rackLocation,
      'image_url': imageUrl,
    };
  }
}

class AdminOrderDetail {
  final String orderId;
  final String orderTime;
  final String? orderDate;
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
  final String? qrCode;
  final String? pickupPoint;
  final String? accountAddress;
  final String? paymentChannel;
  final bool isVerifiedUser;
  final int cashierFee;

  const AdminOrderDetail({
    required this.orderId,
    required this.orderTime,
    this.orderDate,
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
    this.qrCode,
    this.pickupPoint,
    this.accountAddress,
    this.paymentChannel,
    this.isVerifiedUser = true,
    this.cashierFee = 0,
  });

  AdminOrderDetail copyWith({
    String? orderId,
    String? orderTime,
    String? orderDate,
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
    String? qrCode,
    String? pickupPoint,
    String? accountAddress,
    String? paymentChannel,
    bool? isVerifiedUser,
    int? cashierFee,
  }) {
    return AdminOrderDetail(
      orderId: orderId ?? this.orderId,
      orderTime: orderTime ?? this.orderTime,
      orderDate: orderDate ?? this.orderDate,
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
      qrCode: qrCode ?? this.qrCode,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      accountAddress: accountAddress ?? this.accountAddress,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      isVerifiedUser: isVerifiedUser ?? this.isVerifiedUser,
      cashierFee: cashierFee ?? this.cashierFee,
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

  static AdminOrderStatus statusFromString(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'baru':
        return AdminOrderStatus.baru;
      case 'diproses':
        return AdminOrderStatus.diproses;
      case 'siapdiambil':
        return AdminOrderStatus.siapDiambil;
      case 'dalampengiriman':
        return AdminOrderStatus.dalamPengiriman;
      case 'selesai':
        return AdminOrderStatus.selesai;
      case 'dibatalkan':
        return AdminOrderStatus.dibatalkan;
      default:
        return AdminOrderStatus.baru;
    }
  }

  static String statusToString(AdminOrderStatus status) {
    switch (status) {
      case AdminOrderStatus.baru:
        return 'baru';
      case AdminOrderStatus.diproses:
        return 'diproses';
      case AdminOrderStatus.siapDiambil:
        return 'siapDiambil';
      case AdminOrderStatus.dalamPengiriman:
        return 'dalamPengiriman';
      case AdminOrderStatus.selesai:
        return 'selesai';
      case AdminOrderStatus.dibatalkan:
        return 'dibatalkan';
    }
  }

  factory AdminOrderDetail.fromMap(
    Map<String, dynamic> map, [
    List<dynamic>? itemsList,
  ]) {
    String orderTime = 'Hari ini';
    String? orderDate;
    if (map['created_at'] != null) {
      try {
        final dt = DateTime.parse(map['created_at'] as String).toLocal();
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        orderTime = '$hour:$minute WIB';

        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        orderDate =
            '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute WIB';
      } catch (_) {}
    }

    final rawBooks = itemsList ?? (map['order_items'] as List<dynamic>? ?? []);
    final books = rawBooks
        .map((b) => AdminOrderBookItem.fromMap(b as Map<String, dynamic>))
        .toList();

    return AdminOrderDetail(
      orderId: map['id'] as String? ?? '',
      orderTime: orderTime,
      orderDate: orderDate,
      customerName: map['customer_name'] as String? ?? 'Pembeli Toko',
      customerPhone: map['customer_phone'] as String? ?? '-',
      deliveryType: map['delivery_type'] as String? ?? 'Kurir Toko (Delivery)',
      paymentMethod: map['payment_method'] as String? ?? 'Online QRIS',
      paymentChannel: map['payment_channel'] as String?,
      isPaid: map['is_paid'] as bool? ?? false,
      status: statusFromString(map['status'] as String?),
      books: books,
      totalPrice: (map['total_price'] as num?)?.toInt() ?? 0,
      specialNote: map['special_note'] as String?,
      address: map['customer_address'] as String?,
      pickupCode: map['pickup_code'] as String?,
      qrCode: map['qr_code'] as String?,
      pickupPoint: map['pickup_point'] as String?,
      accountAddress: map['account_address'] as String?,
      isVerifiedUser: map['is_verified_user'] as bool? ?? true,
      cashierFee: (map['cashier_fee'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': orderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': address ?? '',
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
      'payment_channel': paymentChannel,
      'is_paid': isPaid,
      'status': statusToString(status),
      'total_price': totalPrice,
      'special_note': specialNote,
      'pickup_code': pickupCode,
      'qr_code': qrCode,
      'pickup_point': pickupPoint,
      'account_address': accountAddress,
      'is_verified_user': isVerifiedUser,
      'cashier_fee': cashierFee,
    };
  }

  static List<AdminOrderDetail> get mockOrders => [
        const AdminOrderDetail(
          orderId: 'ORD00125',
          orderTime: '10:42 WIB',
          orderDate: '12 Mei 2024, 10:42 WIB',
          customerName: 'Budi Santoso',
          customerPhone: '0812-3456-7890',
          deliveryType: 'Ambil di Toko',
          paymentMethod: 'Online QRIS',
          paymentChannel: 'BCA / GoPay Instan',
          isPaid: true,
          status: AdminOrderStatus.siapDiambil,
          pickupPoint: 'Gerai Utama Cikini, Meja Kasir 1 (Jl. Cikini Raya No. 45)',
          accountAddress:
              'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat, DKI Jakarta 10330',
          books: [
            AdminOrderBookItem(
              title: 'Atomic Habits',
              author: 'James Clear',
              rackLocation: 'Rak A-04 (Lantai 1)',
              qty: 1,
              price: 85000,
            ),
            AdminOrderBookItem(
              title: 'Filosofi Teras',
              author: 'Henry Manampiring',
              rackLocation: 'Rak B-12 (Lantai 1)',
              qty: 1,
              price: 65000,
            ),
          ],
          totalPrice: 150000,
          cashierFee: 0,
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
