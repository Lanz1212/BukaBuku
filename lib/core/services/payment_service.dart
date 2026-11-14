import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/monthly_sales_data.dart';
import '../models/payment_monthly_summary.dart';
import '../../features/admin/payment_management/models/payment_transaction.dart';
import 'cashier_log_service.dart';
import 'admin_notification_service.dart';

class PaymentService {
  static SupabaseClient? get _safeClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Helper untuk mengecek apakah metode pembayaran adalah tunai kasir
  static bool isCashPayment(String? paymentMethod) {
    if (paymentMethod == null) return false;
    final lower = paymentMethod.toLowerCase();
    return lower.contains('kasir') || lower.contains('tunai');
  }

  /// Format angka ke Rupiah
  static String formatRupiah(int amount) {
    final str = amount.toString();
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

  /// Mengambil semua transaksi pesanan untuk bulan dan tahun yang ditentukan
  static Future<List<PaymentTransaction>> fetchMonthlyTransactions({
    required int year,
    required int month,
  }) async {
    final client = _safeClient;
    if (client == null) return [];

    try {
      // Range waktu awal bulan sampai awal bulan berikutnya
      final from = DateTime.utc(year, month, 1);
      final to = (month == 12)
          ? DateTime.utc(year + 1, 1, 1)
          : DateTime.utc(year, month + 1, 1);

      final response = await client
          .from('orders')
          .select('*, order_items(*)')
          .gte('created_at', from.toIso8601String())
          .lt('created_at', to.toIso8601String())
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((row) => PaymentTransaction.fromOrderMap(
                row as Map<String, dynamic>,
                row['order_items'] as List<dynamic>?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching monthly transactions: $e');
      return [];
    }
  }

  /// Menghitung ringkasan kas bulanan (Total Kas, Tunai Kasir, Midtrans)
  /// Hanya menghitung pesanan dengan is_paid == true
  static Future<PaymentMonthlySummary> fetchMonthlySummary({
    required int year,
    required int month,
  }) async {
    final client = _safeClient;
    if (client == null) {
      return PaymentMonthlySummary.empty(year: year, month: month);
    }

    try {
      final from = DateTime.utc(year, month, 1);
      final to = (month == 12)
          ? DateTime.utc(year + 1, 1, 1)
          : DateTime.utc(year, month + 1, 1);

      final response = await client
          .from('orders')
          .select('id, total_price, payment_method, is_paid, status')
          .gte('created_at', from.toIso8601String())
          .lt('created_at', to.toIso8601String());

      final list = response as List<dynamic>;

      int totalAmount = 0;
      int cashAmount = 0;
      int midtransAmount = 0;
      int paidCount = 0;
      int pendingCash = 0;

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final isPaid = item['is_paid'] as bool? ?? false;
          final pMethod = item['payment_method'] as String? ?? '';
          final total = (item['total_price'] as num?)?.toInt() ?? 0;
          final status = (item['status'] as String? ?? '').toLowerCase();
          final isCash = isCashPayment(pMethod);

          if (isPaid) {
            totalAmount += total;
            paidCount++;
            if (isCash) {
              cashAmount += total;
            } else {
              midtransAmount += total;
            }
          } else {
            // Cek jika cash yang belum dibayar & tidak dibatalkan
            if (isCash && status != 'dibatalkan') {
              pendingCash++;
            }
          }
        }
      }

      return PaymentMonthlySummary(
        totalAmount: totalAmount,
        cashAmount: cashAmount,
        midtransAmount: midtransAmount,
        year: year,
        month: month,
        totalPaidTransactions: paidCount,
        pendingCashCount: pendingCash,
      );
    } catch (e) {
      debugPrint('Error calculating monthly summary: $e');
      return PaymentMonthlySummary.empty(year: year, month: month);
    }
  }

  /// Konfirmasi pembayaran tunai kasir langsung ke Supabase
  static Future<bool> confirmCashPayment({
    required String rawOrderId,
    required int totalAmount,
    int? receivedAmount,
    int? changeAmount,
    String? customerName,
  }) async {
    final client = _safeClient;
    if (client == null) return false;

    final cleanId = rawOrderId.replaceAll('#', '').trim();
    final now = DateTime.now().toIso8601String();

    try {
      // 1. Dapatkan status pesanan saat ini
      final orderRow = await client
          .from('orders')
          .select('status')
          .eq('id', cleanId)
          .maybeSingle();

      String newStatus = 'diproses';
      if (orderRow != null) {
        final currentStatus = (orderRow['status'] as String? ?? '').toLowerCase();
        // Bila sudah siapDiambil atau selesai, pertahankan alurnya
        if (currentStatus == 'siapdiambil' || currentStatus == 'selesai') {
          newStatus = orderRow['status'];
        }
      }

      // 2. Update status & is_paid di tabel orders
      await client.from('orders').update({
        'is_paid': true,
        'status': newStatus,
        'updated_at': now,
      }).eq('id', cleanId);

      // 3. Catat audit log aktivitas kasir
      final details =
          'Konfirmasi pembayaran kasir sebesar ${formatRupiah(totalAmount)}'
          '${receivedAmount != null ? ' (Diterima: ${formatRupiah(receivedAmount)}, Kembali: ${formatRupiah(changeAmount ?? 0)})' : ''}';

      await CashierLogService.recordLog(
        action: 'Konfirmasi Bayar Kasir',
        details: details,
        orderId: cleanId,
        tag: 'Kasir',
      );

      // 4. Buat notifikasi internal jika tersedia
      try {
        await AdminNotificationService.broadcastToAdmins(
          type: 'payment_confirmed',
          category: 'order',
          title: 'Pembayaran Kasir Diterima 💵',
          body:
              'Pesanan #$cleanId (${customerName ?? "Pelanggan"}) telah dikonfirmasi lunas sebesar ${formatRupiah(totalAmount)}.',
          orderId: cleanId,
        );
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Error confirming cash payment in Supabase: $e');
      return false;
    }
  }

  /// Mengambil data penjualan bulanan untuk tahun yang ditentukan (12 bulan: Jan - Des)
  /// Digunakan untuk grafik penjualan di Admin Dashboard
  /// Jika bulan tersebut tidak ada transaksi, totalRevenue = 0 (bukan data dummy)
  static Future<List<MonthlySalesData>> fetchMonthlySalesChart({
    int? targetYear,
  }) async {
    final client = _safeClient;
    final year = targetYear ?? DateTime.now().year;

    // Buat template 12 bulan bernilai 0
    final Map<int, MonthlySalesData> monthMap = {
      for (int m = 1; m <= 12; m++)
        m: MonthlySalesData(
          year: year,
          month: m,
          totalRevenue: 0,
          orderCount: 0,
        ),
    };

    if (client == null) {
      return monthMap.values.toList();
    }

    try {
      final startOfYear = DateTime.utc(year, 1, 1).toIso8601String();
      final endOfYear = DateTime.utc(year + 1, 1, 1).toIso8601String();

      // Query semua pesanan yang lunas (is_paid = true) di tahun ini
      final response = await client
          .from('orders')
          .select('total_price, created_at')
          .eq('is_paid', true)
          .gte('created_at', startOfYear)
          .lt('created_at', endOfYear);

      final list = response as List<dynamic>;

      final Map<int, int> revenueAcc = {for (int m = 1; m <= 12; m++) m: 0};
      final Map<int, int> countAcc = {for (int m = 1; m <= 12; m++) m: 0};

      for (final row in list) {
        if (row is Map<String, dynamic>) {
          final total = (row['total_price'] as num?)?.toInt() ?? 0;
          final createdAtStr = row['created_at'] as String?;
          if (createdAtStr != null) {
            final dt = DateTime.tryParse(createdAtStr)?.toLocal();
            if (dt != null && dt.year == year) {
              final m = dt.month;
              revenueAcc[m] = (revenueAcc[m] ?? 0) + total;
              countAcc[m] = (countAcc[m] ?? 0) + 1;
            }
          }
        }
      }

      return List.generate(12, (index) {
        final m = index + 1;
        return MonthlySalesData(
          year: year,
          month: m,
          totalRevenue: revenueAcc[m] ?? 0,
          orderCount: countAcc[m] ?? 0,
        );
      });
    } catch (e) {
      debugPrint('Error fetching monthly sales chart: $e');
      return monthMap.values.toList();
    }
  }

  /// Berlangganan event realtime tabel orders untuk auto-refresh halaman kasir & grafik
  static RealtimeChannel? subscribeToPayments({
    required VoidCallback onData,
  }) {
    final client = _safeClient;
    if (client == null) return null;

    try {
      final channelName = 'public:payments_realtime_${DateTime.now().millisecondsSinceEpoch}';
      final channel = client.channel(channelName);
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              onData();
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Error subscribing to payments: $e');
      return null;
    }
  }
}
