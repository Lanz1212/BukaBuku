import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum PaymentStatus {
  needsConfirmation,
  paid,
  pending,
  failed,
}

enum PaymentMethod {
  cashPickup,
  qrisOnline,
  transferVA,
  eWallet,
}

class PaymentTransaction {
  final String orderId;
  final String rawOrderId;
  final String time;
  final DateTime? createdAt;
  final String customerName;
  final String customerPhone;
  final PaymentStatus status;
  final bool isPaid;
  final PaymentMethod method;
  final String methodLabel;
  final int total;
  final List<String> bookTitles;
  final String? deliveryType;
  final String? failureReason;

  const PaymentTransaction({
    required this.orderId,
    required this.rawOrderId,
    required this.time,
    this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.isPaid,
    required this.method,
    required this.methodLabel,
    required this.total,
    required this.bookTitles,
    this.deliveryType,
    this.failureReason,
  });

  String get formattedTotal {
    final str = total.toString();
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

  String get statusLabel {
    switch (status) {
      case PaymentStatus.needsConfirmation:
        return 'Perlu Konfirmasi';
      case PaymentStatus.paid:
        return 'Paid • Lunas';
      case PaymentStatus.pending:
        return 'Menunggu Pembayaran';
      case PaymentStatus.failed:
        return 'Gagal / Batal';
    }
  }

  Color get statusBadgeColor {
    switch (status) {
      case PaymentStatus.needsConfirmation:
        return AppColors.warning;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.pending:
        return const Color(0xFF2E78B7);
      case PaymentStatus.failed:
        return AppColors.error;
    }
  }

  factory PaymentTransaction.fromOrderMap(
    Map<String, dynamic> order, [
    List<dynamic>? items,
  ]) {
    final rawId = (order['id'] ?? '').toString();
    final orderIdFormatted = rawId.startsWith('#') ? rawId : '#$rawId';

    // Parse items
    final rawItems = items ?? (order['order_items'] as List<dynamic>? ?? []);
    final bookTitles = <String>[];
    for (final item in rawItems) {
      if (item is Map<String, dynamic>) {
        final title = item['title'] as String? ?? 'Buku';
        final qty = (item['quantity'] as num?)?.toInt() ?? 1;
        bookTitles.add('$title (x$qty)');
      }
    }

    final pMethod = (order['payment_method'] as String? ?? '').toLowerCase();
    final pChannel = (order['payment_channel'] as String? ?? '').trim();
    final isPaid = order['is_paid'] as bool? ?? false;
    final statusStr = (order['status'] as String? ?? '').toLowerCase();
    final midtransStatus =
        (order['midtrans_transaction_status'] as String? ?? '').toLowerCase();

    // Check cash vs midtrans
    final isCash = pMethod.contains('kasir') || pMethod.contains('tunai');

    PaymentMethod method;
    String methodLabel;

    if (isCash) {
      method = PaymentMethod.cashPickup;
      methodLabel = 'Tunai Kasir';
    } else {
      // Semua non-kasir adalah Midtrans sesuai permintaan user
      final chLower = pChannel.toLowerCase();
      if (chLower.contains('qris') ||
          chLower.contains('gopay') ||
          chLower.contains('dana') ||
          chLower.contains('shopee')) {
        method = PaymentMethod.qrisOnline;
        methodLabel = pChannel.isNotEmpty ? 'Midtrans ($pChannel)' : 'Midtrans (QRIS/E-Wallet)';
      } else if (chLower.contains('va') ||
          chLower.contains('virtual') ||
          chLower.contains('bca') ||
          chLower.contains('mandiri') ||
          chLower.contains('bri') ||
          chLower.contains('bni')) {
        method = PaymentMethod.transferVA;
        methodLabel = pChannel.isNotEmpty ? 'Midtrans ($pChannel)' : 'Midtrans (VA)';
      } else {
        method = PaymentMethod.eWallet;
        methodLabel = pChannel.isNotEmpty ? 'Midtrans ($pChannel)' : 'Midtrans Gateway';
      }
    }

    // Determine Status
    PaymentStatus txStatus;
    if (statusStr == 'dibatalkan' ||
        midtransStatus == 'expire' ||
        midtransStatus == 'cancel' ||
        midtransStatus == 'deny' ||
        midtransStatus == 'failure') {
      txStatus = PaymentStatus.failed;
    } else if (isPaid) {
      txStatus = PaymentStatus.paid;
    } else if (isCash) {
      txStatus = PaymentStatus.needsConfirmation;
    } else {
      txStatus = PaymentStatus.pending;
    }

    // Parse DateTime
    DateTime? createdAt;
    if (order['created_at'] != null) {
      createdAt = DateTime.tryParse(order['created_at'].toString())?.toLocal();
    }

    final timeStr = _formatTimestamp(createdAt);

    return PaymentTransaction(
      orderId: orderIdFormatted,
      rawOrderId: rawId,
      time: timeStr,
      createdAt: createdAt,
      customerName: order['customer_name'] as String? ?? 'Pelanggan',
      customerPhone: order['customer_phone'] as String? ?? '-',
      status: txStatus,
      isPaid: isPaid,
      method: method,
      methodLabel: methodLabel,
      total: (order['total_price'] as num?)?.toInt() ?? 0,
      bookTitles: bookTitles,
      deliveryType: order['delivery_type'] as String?,
      failureReason: txStatus == PaymentStatus.failed
          ? (order['special_note'] as String? ?? 'Pesanan dibatalkan / kedaluwarsa')
          : null,
    );
  }

  static String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '-';
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;

    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hari ini, $hour:$minute WIB';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final mName = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
    return '${dt.day} $mName ${dt.year}, $hour:$minute WIB';
  }
}
