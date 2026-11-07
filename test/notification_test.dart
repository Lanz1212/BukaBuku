import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/notification/models/notification_model.dart';

void main() {
  group('NotificationModel Tests', () {
    test('Parses from Supabase map correctly for paymentSuccess', () {
      final now = DateTime.now().subtract(const Duration(minutes: 5));
      final map = {
        'id': 'notif-001',
        'user_id': 'user-123',
        'order_id': 'ORD00125',
        'category': 'order',
        'type': 'paymentSuccess',
        'title': 'Pembayaran Berhasil!',
        'body': 'Pembayaran untuk pesanan #ORD00125 telah terverifikasi.',
        'is_unread': true,
        'ref_id': 'QRIS-12345',
        'created_at': now.toIso8601String(),
      };

      final notif = NotificationModel.fromSupabase(map);

      expect(notif.id, 'notif-001');
      expect(notif.title, 'Pembayaran Berhasil!');
      expect(notif.body, 'Pembayaran untuk pesanan #ORD00125 telah terverifikasi.');
      expect(notif.category, NotificationCategory.order);
      expect(notif.type, NotificationType.paymentSuccess);
      expect(notif.isUnread, true);
      expect(notif.orderId, '#ORD00125');
      expect(notif.refId, 'QRIS-12345');
      expect(notif.timeAgo, contains('menit'));
    });

    test('Parses orderPickupReady type correctly', () {
      final map = {
        'id': 'notif-002',
        'user_id': 'user-123',
        'order_id': 'ORD00126',
        'category': 'order',
        'type': 'orderPickupReady',
        'title': 'Pesananmu Siap Diambil di Toko!',
        'body': 'Pesanan #ORD00126 siap diambil di kasir.',
        'is_unread': false,
        'store_name': 'Gerai Utama Buka Buku',
        'created_at': DateTime.now().toIso8601String(),
      };

      final notif = NotificationModel.fromSupabase(map);

      expect(notif.type, NotificationType.orderPickupReady);
      expect(notif.storeName, 'Gerai Utama Buka Buku');
      expect(notif.isUnread, false);
      expect(notif.timeAgo, 'Baru saja');
    });

    test('copyWith updates isUnread accurately', () {
      final notif = NotificationModel(
        id: 'test-1',
        title: 'Title',
        body: 'Body',
        category: NotificationCategory.order,
        type: NotificationType.orderProcessing,
        createdAt: DateTime.now(),
        isUnread: true,
      );

      final readNotif = notif.copyWith(isUnread: false);
      expect(readNotif.isUnread, false);
      expect(readNotif.id, 'test-1');
    });
  });
}

