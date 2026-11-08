import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/order/models/order_model.dart';
import 'package:buka_buku/core/services/order_service.dart';
import 'package:buka_buku/core/services/midtrans_service.dart';

void main() {
  group('Midtrans & Cancellation Logic Tests', () {
    test('OrderStatus enum has cancelled state and correct label', () {
      expect(OrderStatus.values.contains(OrderStatus.cancelled), isTrue);
      expect(OrderStatus.cancelled.label, equals('Dibatalkan'));
    });

    test('OrderService maps "dibatalkan" status to OrderStatus.cancelled and sets timeline', () {
      final mockOrderRow = {
        'id': 'ORD-TEST-CANCEL-001',
        'status': 'dibatalkan',
        'is_paid': false,
        'total_price': 89000,
        'delivery_type': 'Ambil di Toko',
        'payment_method': 'Midtrans Payment Gateway',
        'created_at': DateTime.now().toIso8601String(),
        'order_items': [
          {
            'id': 1,
            'book_id': 'B001',
            'title': 'Buku Uji',
            'author': 'Penulis Uji',
            'price': 89000,
            'quantity': 1,
          }
        ],
      };

      final orderModel = OrderService.mapRowToOrderModel(mockOrderRow);

      expect(orderModel.status, equals(OrderStatus.cancelled));
      expect(orderModel.isPaid, isFalse);
      expect(orderModel.timeline.any((t) => t.title == 'Pembayaran Dibatalkan'), isTrue);
    });

    test('MidtransTransactionStatus isPaid recognizes settlement, success, and capture accept', () {
      final statusSettlement = MidtransTransactionStatus.fromJson({
        'transaction_status': 'settlement',
        'status_code': '200',
      }, 'ORD1');
      expect(statusSettlement.isPaid, isTrue);

      final statusSuccess = MidtransTransactionStatus.fromJson({
        'transaction_status': 'success',
        'status_code': '200',
      }, 'ORD2');
      expect(statusSuccess.isPaid, isTrue);

      final statusCaptureAccept = MidtransTransactionStatus.fromJson({
        'transaction_status': 'capture',
        'fraud_status': 'accept',
        'status_code': '200',
      }, 'ORD3');
      expect(statusCaptureAccept.isPaid, isTrue);

      final statusPending = MidtransTransactionStatus.fromJson({
        'transaction_status': 'pending',
        'status_code': '201',
      }, 'ORD4');
      expect(statusPending.isPaid, isFalse);
      expect(statusPending.isPending, isTrue);

      final statusCancel = MidtransTransactionStatus.fromJson({
        'transaction_status': 'cancel',
        'status_code': '202',
      }, 'ORD5');
      expect(statusCancel.isPaid, isFalse);
      expect(statusCancel.isFailed, isTrue);
    });
  });
}

