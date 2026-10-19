import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/order/models/order_simulation_flow.dart';
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
      expect(find.text('QRIS (GoPay/BCA)'), findsOneWidget);

      // Books Section
      expect(find.text('RINCIAN BUKU (2)'), findsOneWidget);
      expect(find.text('Paket Kurir Terproteksi'), findsOneWidget);
      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.text('James Clear • 1x Hardcover'), findsOneWidget);
      expect(find.text('Rp108.000'), findsOneWidget);
      expect(find.text('Filosofi Teras'), findsOneWidget);
      expect(find.text('Henry Manampiring • 1x Softcover'), findsOneWidget);
      expect(find.text('Rp73.000'), findsOneWidget);

      // Delivery Destination
      expect(find.text('Kurir Antar ke Rumah'), findsOneWidget);
      expect(
        find.text('Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat'),
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
    testWidgets('renders all visual elements and switches simulation flows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderSuccessScreen(
            orderId: '#ORD00125',
            initialFlow: OrderSimulationFlow.pickupCash,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top Bar
      expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
      expect(find.text('Budi Express'), findsOneWidget);

      // Simulation Tabs
      expect(find.text('1. Antar Rumah'), findsOneWidget);
      expect(find.text('2. Ambil Online'), findsOneWidget);
      expect(find.text('3. Bayar Kasir'), findsOneWidget);

      // Hero Elements
      expect(find.text('Pesanan Berhasil Dibuat!'), findsOneWidget);
      expect(
        find.text('Nomor pesananmu telah tercatat di sistem Toko Buku Budi.'),
        findsOneWidget,
      );

      // Summary Card
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Salin'), findsOneWidget);
      expect(find.text('12 Mei 2024'), findsOneWidget);
      expect(find.text('2 Buku Fisik'), findsOneWidget);
      expect(find.text('1x Atomic Habits (James Clear)'), findsOneWidget);
      expect(find.text('1x Filosofi Teras (Henry M.)'), findsOneWidget);
      expect(find.text('Rp169.000'), findsOneWidget);

      // Cashier Specific Content (Flow 3: Bayar Kasir is active)
      expect(find.text('Pengambilan & Pembayaran Kasir'), findsOneWidget);
      expect(find.text('Siapkan Uang Pas Rp169.000'), findsOneWidget);
      expect(find.text('SCAN QR CODE DI KASIR TOKO'), findsOneWidget);
      expect(find.text('ORD-00125-CKN'), findsOneWidget);

      // Timeline Section
      expect(find.text('Langkah Selanjutnya'), findsOneWidget);
      expect(find.text('1. Pesanan Diterima'), findsOneWidget);
      expect(find.text('2. Pengepakan Buku & Pembatas Kayu'), findsOneWidget);
      expect(find.text('3. Siap Diambil di Rak Toko'), findsOneWidget);

      // Test Switching to Flow 1: Antar Rumah
      await tester.tap(find.text('1. Antar Rumah'));
      await tester.pumpAndSettle();

      // Should now show delivery fee & total Rp181.000
      expect(find.text('Ongkos Kirim Kurir Toko'), findsOneWidget);
      expect(find.text('Rp181.000'), findsOneWidget);
      expect(find.text('Informasi Pengantaran'), findsOneWidget);
      expect(find.text('3. Siap Dikirim Kurir'), findsOneWidget);

      // Test Switching to Flow 2: Ambil Online
      await tester.tap(find.text('2. Ambil Online'));
      await tester.pumpAndSettle();

      expect(find.text('Pengambilan di Toko'), findsOneWidget);
      expect(find.text('3. Siap Diambil di Rak Toko'), findsOneWidget);
      expect(find.text('Rp169.000'), findsOneWidget);

      // Action Buttons
      expect(find.text('Lihat Pesanan'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });
  });
}
