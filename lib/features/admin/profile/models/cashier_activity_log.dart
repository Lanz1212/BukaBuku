/// Model untuk Log Aktivitas Kasir Buka Buku
class CashierActivityLog {
  final String id;
  final DateTime createdAt;
  final String cashierName;
  final String action;
  final String? details;
  final String? orderId;
  final String tag;

  const CashierActivityLog({
    required this.id,
    required this.createdAt,
    required this.cashierName,
    required this.action,
    this.details,
    this.orderId,
    this.tag = 'Kasir',
  });

  factory CashierActivityLog.fromMap(Map<String, dynamic> map) {
    return CashierActivityLog(
      id: map['id']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cashierName: map['cashier_name'] as String? ?? 'Staf Kasir',
      action: map['action'] as String? ?? 'Aktivitas Kasir',
      details: map['details'] as String?,
      orderId: map['order_id'] as String?,
      tag: map['tag'] as String? ?? 'Kasir',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cashier_name': cashierName,
      'action': action,
      'details': details,
      'order_id': orderId,
      'tag': tag,
    };
  }
}

