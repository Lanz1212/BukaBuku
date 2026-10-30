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
  final String time;
  final String customerName;
  final String customerPhone;
  final PaymentStatus status;
  final PaymentMethod method;
  final String methodLabel;
  final int total;
  final List<String> bookTitles;
  final String? deliveryType;
  final String? failureReason;

  const PaymentTransaction({
    required this.orderId,
    required this.time,
    required this.customerName,
    required this.customerPhone,
    required this.status,
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
        return 'Kedaluwarsa';
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

  static List<PaymentTransaction> get mockTransactions => [
        const PaymentTransaction(
          orderId: '#ORD00127',
          time: 'Hari ini, 10:48 WIB',
          customerName: 'Ahmad Fikri',
          customerPhone: '0857-1234-9087',
          status: PaymentStatus.needsConfirmation,
          method: PaymentMethod.cashPickup,
          methodLabel: 'Cash Kasir (Pickup)',
          total: 310000,
          deliveryType: 'Ambil di Toko',
          bookTitles: [
            'Psychology of Money (x1)',
            'Sapiens: Riwayat Singkat (x1)',
            'Filosofi Teras (x1)',
          ],
        ),
        const PaymentTransaction(
          orderId: '#ORD00125',
          time: 'Hari ini, 10:42 WIB',
          customerName: 'Budi Santoso',
          customerPhone: '0812-3456-7890',
          status: PaymentStatus.paid,
          method: PaymentMethod.qrisOnline,
          methodLabel: 'QRIS BCA Instan',
          total: 150000,
          deliveryType: 'Ambil di Toko',
          bookTitles: [
            'Atomic Habits (x1)',
            'Filosofi Teras (x1)',
          ],
        ),
        const PaymentTransaction(
          orderId: '#ORD00126',
          time: 'Hari ini, 10:15 WIB',
          customerName: 'Siti Rahma',
          customerPhone: '0813-8899-2341',
          status: PaymentStatus.paid,
          method: PaymentMethod.transferVA,
          methodLabel: 'Transfer VA BCA',
          total: 85000,
          deliveryType: 'Kurir Reguler (Delivery)',
          bookTitles: [
            'Laut Bercerita (x1)',
          ],
        ),
        const PaymentTransaction(
          orderId: '#ORD00128',
          time: 'Hari ini, 09:50 WIB',
          customerName: 'Rian Pratama',
          customerPhone: '0819-4455-6677',
          status: PaymentStatus.pending,
          method: PaymentMethod.qrisOnline,
          methodLabel: 'QRIS GoPay Instan',
          total: 120000,
          deliveryType: 'Ambil di Toko',
          bookTitles: [
            'Bumi Manusia (x1)',
          ],
        ),
        const PaymentTransaction(
          orderId: '#ORD00123',
          time: 'Hari ini, 08:30 WIB',
          customerName: 'Dewi Lestari',
          customerPhone: '0878-9988-7766',
          status: PaymentStatus.failed,
          method: PaymentMethod.eWallet,
          methodLabel: 'E-Wallet ShopeePay',
          total: 95000,
          deliveryType: 'Kurir Reguler (Delivery)',
          failureReason: 'Batas waktu pembayaran 15 menit terlewati',
          bookTitles: [
            'Cantik Itu Luka (x1)',
          ],
        ),
      ];
}
