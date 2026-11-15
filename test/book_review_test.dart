import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/review/models/book_review.dart';
import 'package:buka_buku/features/order/models/order_item_model.dart';
import 'package:buka_buku/features/admin/book_management/models/admin_book_item.dart';
import 'package:buka_buku/features/admin/order_management/models/admin_order_detail.dart';
import 'package:buka_buku/core/services/order_service.dart';

void main() {
  group('BookReview Model & Logic Tests', () {
    test('BookReview parses from Supabase map correctly', () {
      final map = {
        'id': 10,
        'book_id': 'B003',
        'user_id': 'fa1b028e-3818-4071-afad-cd6c90ddbf25',
        'order_id': 'ORD2611070967',
        'user_name': 'Budi Santoso',
        'user_avatar': null,
        'rating': 5,
        'comment': 'Buku yang sangat bagus dan inspiratif.',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      };

      final review = BookReview.fromMap(map);
      expect(review.id, 10);
      expect(review.bookId, 'B003');
      expect(review.userName, 'Budi Santoso');
      expect(review.reviewerInitials, 'BS');
      expect(review.rating, 5);
      expect(review.comment, 'Buku yang sangat bagus dan inspiratif.');
      expect(review.timeAgo, '2 hari lalu');
    });

    test('Single-word names generate correct initials', () {
      final review = BookReview(
        id: 1,
        bookId: 'B001',
        userId: 'u1',
        orderId: 'ORD1',
        userName: 'Rendra',
        rating: 4,
        comment: 'Keren',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(review.reviewerInitials, 'RE');
      expect(review.timeAgo, '3 jam lalu');
    });

    test('OrderItemModel holds bookId and computes correct subtotals', () {
      const item1 = OrderItemModel(
        id: 'item-1',
        bookId: 'B012',
        title: 'One Piece Vol. 100',
        author: 'Eiichiro Oda',
        coverUrl: 'https://example.com/op.jpg',
        quantity: 2,
        pricePerUnit: 'Rp45.000',
        pricePerUnitValue: 45000,
        subtotal: 'Rp90.000',
        subtotalValue: 90000,
      );

      const item2 = OrderItemModel(
        id: 'item-2',
        bookId: 'B003',
        title: 'Laut Bercerita',
        author: 'Leila S. Chudori',
        coverUrl: 'https://example.com/lb.jpg',
        quantity: 1,
        pricePerUnit: 'Rp105.000',
        pricePerUnitValue: 105000,
        subtotal: 'Rp105.000',
        subtotalValue: 105000,
      );

      expect(item1.bookId, 'B012');
      expect(item2.bookId, 'B003');
      expect(item1.subtotalValue, 90000);
      expect(item2.subtotalValue, 105000);

      final totalSubtotal = item1.subtotalValue + item2.subtotalValue;
      expect(totalSubtotal, 195000);
    });

    test('AdminBookItem defaults to rating 0.0 and reviewCount 0 for new books', () {
      const newBook = AdminBookItem(
        id: 'B015',
        title: 'Buku Baru',
        author: 'Penulis Baru',
        isbn: '978-1234567890',
        price: 50000,
        stock: 10,
        rackLocation: 'Rak A1',
        status: AdminBookStatus.tersedia,
        isActive: true,
        category: 'Non-Fiksi',
        coverUrl: 'https://example.com/cover.jpg',
      );

      expect(newBook.rating, 0.0);
      expect(newBook.reviewCount, 0);

      // Verify fromMap also falls back to 0.0 when rating is null
      final fromDb = AdminBookItem.fromMap({
        'id': 'B015',
        'title': 'Buku Baru',
        'author': 'Penulis Baru',
        'isbn': '978-1234567890',
        'price': 50000,
        'stock': 10,
        'rack_location': 'Rak A1',
        'category': 'Non-Fiksi',
        'cover_url': 'https://example.com/cover.jpg',
      });
      expect(fromDb.rating, 0.0);
      expect(fromDb.reviewCount, 0);
    });

    test('AdminOrderDetail and OrderService correctly parse UTC timestamp to local time', () {
      // 08:00:00 UTC corresponds to local time + timezone offset
      final utcStr = '2026-11-15T08:00:00+00:00';
      final expectedLocal = DateTime.parse(utcStr).toLocal();
      final expectedHour = expectedLocal.hour.toString().padLeft(2, '0');
      final expectedMinute = expectedLocal.minute.toString().padLeft(2, '0');
      final expectedTimeStr = '$expectedHour:$expectedMinute WIB';

      final adminOrder = AdminOrderDetail.fromMap({
        'id': 'ORDTEST001',
        'customer_name': 'Tester',
        'created_at': utcStr,
      });

      expect(adminOrder.orderTime, expectedTimeStr);

      final userOrder = OrderService.mapRowToOrderModel({
        'id': 'ORDTEST001',
        'created_at': utcStr,
        'order_items': [],
      });
      expect(userOrder.dateTimeStr.contains(expectedTimeStr), isTrue);
    });
  });
}

