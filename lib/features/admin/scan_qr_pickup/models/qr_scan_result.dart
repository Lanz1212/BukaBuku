import '../../order_management/models/admin_order_detail.dart';

class QrScanResult {
  final String orderId;
  final String customerName;
  final int bookCount;
  final int totalPrice;
  final String status;
  final String verificationTime;
  final AdminOrderDetail? fullOrder;

  const QrScanResult({
    required this.orderId,
    required this.customerName,
    required this.bookCount,
    required this.totalPrice,
    this.status = 'Siap Diambil',
    this.verificationTime = '0.3s',
    this.fullOrder,
  });

  String get formattedPrice {
    final str = totalPrice.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  factory QrScanResult.fromOrder(AdminOrderDetail order) {
    return QrScanResult(
      orderId: order.orderId.startsWith('#') ? order.orderId : '#${order.orderId}',
      customerName: order.customerName,
      bookCount: order.books.fold<int>(0, (sum, item) => sum + item.qty),
      totalPrice: order.totalPrice,
      status: order.statusLabel,
      verificationTime: '0.3s',
      fullOrder: order,
    );
  }

  static QrScanResult mockDefault() {
    return const QrScanResult(
      orderId: '#ORD00125',
      customerName: 'Budi Santoso',
      bookCount: 2,
      totalPrice: 150000,
      status: 'Siap Diambil',
      verificationTime: '0.3s',
    );
  }
}
