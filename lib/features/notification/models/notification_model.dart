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
  final String timeAgo;
  final String body;
  final NotificationCategory category;
  final NotificationType type;
  final bool isUnread;
  final IconData icon;
  final String? orderId;
  final String? refId;
  final String? storeName;
  final String? deliveryEta;
  final String? voucherCode;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.timeAgo,
    required this.body,
    required this.category,
    required this.type,
    this.isUnread = false,
    required this.icon,
    this.orderId,
    this.refId,
    this.storeName,
    this.deliveryEta,
    this.voucherCode,
  });

  NotificationModel copyWith({
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      timeAgo: timeAgo,
      body: body,
      category: category,
      type: type,
      isUnread: isUnread ?? this.isUnread,
      icon: icon,
      orderId: orderId,
      refId: refId,
      storeName: storeName,
      deliveryEta: deliveryEta,
      voucherCode: voucherCode,
    );
  }
}

/// Mock Notifications matching Toko Buku Budi Stitch specification
final List<NotificationModel> mockNotifications = [
  const NotificationModel(
    id: 'notif-1',
    title: 'Pesananmu Siap Diambil di Toko!',
    timeAgo: '10 menit yang lalu',
    body:
        'Pesanan #ORD00125 sudah selesai dikemas dan siap diambil di kasir Toko Buku Budi Cikini. Tunjukkan QR Pickup saat tiba.',
    category: NotificationCategory.order,
    type: NotificationType.orderPickupReady,
    isUnread: true,
    icon: Icons.storefront_outlined,
    orderId: '#ORD00125',
    storeName: 'Toko Buku Budi Cikini',
  ),
  const NotificationModel(
    id: 'notif-2',
    title: 'Buku Sedang Diantar Kurir',
    timeAgo: '2 jam yang lalu',
    body:
        'Pesanan #ORD00118 sedang dalam perjalanan menuju alamatmu oleh Kurir Toko Budi Express.',
    category: NotificationCategory.order,
    type: NotificationType.orderShipping,
    isUnread: false,
    icon: Icons.local_shipping_outlined,
    orderId: '#ORD00118',
    deliveryEta: 'Estimasi tiba sore ini',
  ),
  const NotificationModel(
    id: 'notif-3',
    title: 'Pembayaran QRIS Berhasil',
    timeAgo: '3 jam yang lalu',
    body:
        'Pembayaran untuk pesanan #ORD00125 sebesar Rp181.000 telah terverifikasi otomatis.',
    category: NotificationCategory.order,
    type: NotificationType.paymentSuccess,
    isUnread: false,
    icon: Icons.check_circle_outline,
    orderId: '#ORD00125',
    refId: 'QRIS-9928104',
  ),
  const NotificationModel(
    id: 'notif-4',
    title: 'Pesanan Mulai Diproses Kurator',
    timeAgo: '5 jam yang lalu',
    body:
        'Buku pilihanmu sedang disiapkan dan disampul rapi dengan kertas kraft ramah lingkungan khas Toko Budi.',
    category: NotificationCategory.order,
    type: NotificationType.orderProcessing,
    isUnread: false,
    icon: Icons.auto_stories_outlined,
  ),
  const NotificationModel(
    id: 'notif-5',
    title: 'Pesanan Telah Selesai',
    timeAgo: '28 Apr 2024',
    body:
        'Terima kasih telah mengambil buku pesanan #ORD00094. Berikan ulasan untuk bacaan barumu.',
    category: NotificationCategory.order,
    type: NotificationType.orderCompleted,
    isUnread: false,
    icon: Icons.task_alt_outlined,
    orderId: '#ORD00094',
  ),
  const NotificationModel(
    id: 'notif-6',
    title: 'Voucher Komunitas Pembaca: Diskon Rp15.000',
    timeAgo: '3 hari yang lalu',
    body:
        'Gunakan kode BUDISANTAI untuk koleksi buku fiksi dan non-fiksi pilihan minggu ini.',
    category: NotificationCategory.promo,
    type: NotificationType.promoVoucher,
    isUnread: false,
    icon: Icons.loyalty_outlined,
    voucherCode: 'BUDISANTAI',
  ),
];
