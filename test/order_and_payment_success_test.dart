import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/order/screens/order_success_screen.dart';
import 'package:buka_buku/features/payment/screens/payment_success_screen.dart';

void main() {
  group('PaymentSuccessScreen Tests', () {
    testWidgets('renders all visual elements matching Stitch design',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentSuccessScreen(
            orderId: '#ORD00125',
            totalAmount: 181000,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Top Bar
      expect(find.text('Status Transaksi'), findsOneWidget);

      // Hero Elements
      expect(find.text('Lunas (Terverifikasi Otomatis)'), findsOneWidget);
      expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
      expect(
        find.text(
            'Terima kasih, pembayaranmu telah kami terima dan buku sedang disiapkan dengan cermat.'),
        findsOneWidget,
      );

      // Bento Card Elements
      expect(find.text('TOTAL PEMBAYARAN'), findsOneWidget);
      expect(find.text('Rp181.000'), findsOneWidget);
      expect(find.text('Nomor Pesanan'), findsOneWidget);
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('12 Mei 2024, 14:32 WIB'), findsOneWidget);
      expect(find.textContaining('QRIS'), findsWidgets);

      // Books Section
      expect(find.text('RINCIAN BUKU (2)'), findsOneWidget);
      expect(find.text('Paket Kurir Terproteksi'), findsOneWidget);
      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.textContaining('James Clear'), findsOneWidget);
      expect(find.text('Rp85.000'), findsOneWidget);
      expect(find.text('Filosofi Teras'), findsOneWidget);
      expect(find.textContaining('Henry Manampiring'), findsOneWidget);
      expect(find.text('Rp98.000'), findsOneWidget);

      // Delivery Destination
      expect(find.text('Ambil di Toko'), findsOneWidget);
      expect(
        find.textContaining('Cikini Raya'),
        findsOneWidget,
      );

      // WhatsApp Update Banner
      expect(find.text('Update Resi Otomatis'), findsOneWidget);

      // Action Buttons
      expect(find.text('Lihat Pesanan'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });
  });

  group('OrderSuccessScreen Tests', () {
    testWidgets('renders all real visual elements without testing tabs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderSuccessScreen(
            orderId: '#ORD00125',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Top Bar
      expect(find.text('Konfirmasi Pesanan'), findsOneWidget);

      // Hero Elements
      expect(find.text('Pembayaran & Pesanan Berhasil!'), findsOneWidget);

      // Summary Card
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Salin'), findsOneWidget);

      // Timeline Section
      expect(find.text('Langkah Selanjutnya'), findsOneWidget);
      expect(find.text('1. Pesanan Diterima'), findsOneWidget);
      expect(find.text('2. Pengepakan Buku & Pembatas Kayu'), findsOneWidget);

      // Action Buttons
      expect(find.text('Lihat Pesanan'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });
  });
}
