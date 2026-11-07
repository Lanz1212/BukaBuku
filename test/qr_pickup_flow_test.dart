import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/core/services/order_service.dart';
import 'package:buka_buku/features/order/models/order_model.dart';
import 'package:buka_buku/features/order/screens/pickup_success_screen.dart';
import 'package:buka_buku/features/order/screens/qr_pickup_screen.dart';

void main() {
  group('QR Pickup End-to-End Real Database Mapping Tests', () {
    test('mapRowToOrderModel correctly parses database row with pickup_confirmed_at', () {
      final dbRow = {
        'id': 'ORD2611078899',
        'customer_name': 'Rian Pratama',
        'customer_phone': '081299887766',
        'customer_address': 'Jl. Kemang Raya No. 10',
        'delivery_type': 'Ambil di Toko (Pickup)',
        'payment_method': 'QRIS BCA',
        'is_paid': true,
        'status': 'selesai',
        'total_price': 175000,
        'pickup_point': 'Gerai Buka Buku Menteng',
        'qr_code': 'ORD2611078899',
        'created_at': '2026-11-07T10:00:00Z',
        'pickup_confirmed_at': '2026-11-07T14:35:00Z',
        'order_items': [
          {
            'id': '101',
            'book_id': 'b1',
            'title': 'Filosofi Teras',
            'author': 'Henry Manampiring',
            'quantity': 1,
            'price': 98000,
            'image_url': 'https://example.com/cover1.jpg',
          },
          {
            'id': '102',
            'book_id': 'b2',
            'title': 'Laut Bercerita',
            'author': 'Leila S. Chudori',
            'quantity': 1,
            'price': 77000,
            'image_url': 'https://example.com/cover2.jpg',
          },
        ],
      };

      final order = OrderService.mapRowToOrderModel(dbRow);

      expect(order.id, '#ORD2611078899');
      expect(order.customerName, 'Rian Pratama');
      expect(order.deliveryType, DeliveryType.pickup);
      expect(order.status, OrderStatus.completed);
      expect(order.totalAmount, 'Rp175.000');
      expect(order.items.length, 2);
      expect(order.items[0].title, 'Filosofi Teras');
      expect(order.items[1].title, 'Laut Bercerita');
      expect(order.completionDate, isNotNull);
      expect(order.completionDate, contains('Nov 2026'));
      expect(order.branchName, 'Gerai Buka Buku Menteng');
    });

    testWidgets('User PickupSuccessScreen renders dynamic database items',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dbRow = {
        'id': 'ORD2611078899',
        'customer_name': 'Rian Pratama',
        'customer_phone': '081299887766',
        'customer_address': 'Jl. Kemang Raya No. 10',
        'delivery_type': 'Ambil di Toko (Pickup)',
        'payment_method': 'QRIS BCA',
        'is_paid': true,
        'status': 'selesai',
        'total_price': 175000,
        'pickup_point': 'Gerai Buka Buku Menteng',
        'qr_code': 'ORD2611078899',
        'created_at': '2026-11-07T10:00:00Z',
        'pickup_confirmed_at': '2026-11-07T14:35:00Z',
        'order_items': [
          {
            'id': '101',
            'book_id': 'b1',
            'title': 'Filosofi Teras',
            'author': 'Henry Manampiring',
            'quantity': 1,
            'price': 98000,
            'image_url': 'https://example.com/cover1.jpg',
          },
          {
            'id': '102',
            'book_id': 'b2',
            'title': 'Laut Bercerita',
            'author': 'Leila S. Chudori',
            'quantity': 1,
            'price': 77000,
            'image_url': 'https://example.com/cover2.jpg',
          },
        ],
      };

      final order = OrderService.mapRowToOrderModel(dbRow);

      await tester.pumpWidget(
        MaterialApp(
          home: PickupSuccessScreen(order: order),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dynamic header and customer
      expect(find.text('#ORD2611078899'), findsOneWidget);
      expect(find.text('Rian Pratama'), findsOneWidget);
      expect(find.text('Rp175.000'), findsOneWidget);

      // Verify dynamic book items from database
      expect(find.text('Filosofi Teras'), findsOneWidget);
      expect(find.text('Henry Manampiring'), findsOneWidget);
      expect(find.text('Laut Bercerita'), findsOneWidget);
      expect(find.text('Leila S. Chudori'), findsOneWidget);
      expect(find.text('2 Fisik + Souvenir'), findsOneWidget);

      // Verify no static fake text
      expect(find.text('Atomic Habits'), findsNothing);
    });

    testWidgets('User QrPickupScreen renders QR and live status banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final dbRow = {
        'id': 'ORD2611071234',
        'customer_name': 'Dewi Sartika',
        'customer_phone': '081300112233',
        'customer_address': 'Jl. Cikini Raya',
        'delivery_type': 'Ambil di Toko',
        'payment_method': 'QRIS',
        'is_paid': true,
        'status': 'siapDiambil',
        'total_price': 85000,
        'pickup_point': 'Meja Kasir 1',
        'qr_code': 'ORD2611071234',
        'created_at': '2026-11-07T10:00:00Z',
        'order_items': [
          {
            'id': '201',
            'book_id': 'b1',
            'title': 'Bumi Manusia',
            'author': 'Pramoedya Ananta Toer',
            'quantity': 1,
            'price': 85000,
          },
        ],
      };

      final order = OrderService.mapRowToOrderModel(dbRow);

      await tester.pumpWidget(
        MaterialApp(
          home: QrPickupScreen(order: order),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('QR Pickup'), findsOneWidget);
      expect(find.text('Pesanan Siap Diambil di Meja Kasir Toko'), findsOneWidget);
      expect(find.text('#ORD2611071234'), findsWidgets);
      expect(find.text('Dewi Sartika'), findsOneWidget);
      expect(find.text('ORD2611071234'), findsOneWidget);
    });
  });
}

