import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/order/models/order_model.dart';
import 'package:buka_buku/features/order/screens/order_list_screen.dart';
import 'package:buka_buku/features/order/screens/order_detail_screen.dart';

void main() {
  group('Pesanan Saya (OrderListScreen) Tests', () {
    testWidgets('renders all visual elements matching Stitch design',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderListScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header & Subheader
      expect(find.text('Pesanan Saya'), findsNWidgets(2)); // AppBar and Subheader
      expect(find.text('1 Perlu Diambil'), findsOneWidget);
      expect(
        find.text(
            'Lacak status buku pesanan, kode pickup, dan riwayat belanja Anda.'),
        findsOneWidget,
      );

      // Filter Chips
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Diproses'), findsWidgets);
      expect(find.text('Dikirim'), findsWidgets);
      expect(find.text('Siap Diambil'), findsWidgets);
      expect(find.text('Selesai'), findsWidgets);

      // Cards
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Laut Bercerita & 1 Buku Lainnya'), findsOneWidget);
      expect(find.text('Rp181.000'), findsOneWidget);
      expect(find.text('Tampilkan QR Pickup'), findsOneWidget);

      expect(find.text('#ORD00118'), findsOneWidget);
      expect(find.text('Cantik Itu Luka (Edisi Khusus)'), findsOneWidget);
      expect(find.text('Kurir Buku Budi Express'), findsOneWidget);

      expect(find.text('#ORD00094'), findsOneWidget);
      expect(find.text('Nusantara: Sejarah Silang Budaya'), findsOneWidget);
      expect(find.text('Beri Ulasan'), findsOneWidget);
      expect(find.text('Beli Lagi'), findsOneWidget);

      // Brand Story Card
      expect(find.text('Sentuhan Kasih Toko Buku Budi'), findsOneWidget);
      expect(find.text('Gratis Pembatas Kayu'), findsOneWidget);
      expect(find.text('Garansi Buku Asli'), findsOneWidget);
    });

    testWidgets('tapping Tampilkan QR Pickup opens QR modal bottom sheet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderListScreen(),
        ),
      );
      await tester.pump();

      // Tap Tampilkan QR Pickup
      final qrButton = find.text('Tampilkan QR Pickup');
      expect(qrButton, findsOneWidget);
      await tester.tap(qrButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // QR modal content
      expect(find.text('QR Pickup Pesanan'), findsOneWidget);
      expect(find.text('PKP-880-CJK'), findsOneWidget);
      expect(find.text('Budi Darmawan'), findsOneWidget);

      // Close modal
      final closeButton = find.text('Tutup');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('QR Pickup Pesanan'), findsNothing);
    });

    testWidgets('tapping filter chip filters the order list',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderListScreen(),
        ),
      );
      await tester.pump();

      // Tap Dikirim filter
      final dikirimFilter = find.text('Dikirim');
      expect(dikirimFilter, findsOneWidget);
      await tester.tap(dikirimFilter);
      await tester.pump();

      // Only #ORD00118 should be shown
      expect(find.text('#ORD00118'), findsOneWidget);
      expect(find.text('#ORD00125'), findsNothing);
      expect(find.text('#ORD00094'), findsNothing);
    });
  });

  group('Detail Pesanan (OrderDetailScreen) Tests', () {
    testWidgets('renders all visual elements matching Stitch design',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final order = mockOrders.first; // #ORD00125

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailScreen(order: order),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header & Status Banner
      expect(find.text('Detail Pesanan'), findsOneWidget);
      expect(find.text('Pesanan Siap Diambil di Toko'), findsOneWidget);
      expect(find.text('Paket buku telah dirapikan & siap di kasir Cikini.'),
          findsOneWidget);

      // Order Meta
      expect(find.text('Nomor Pesanan'), findsOneWidget);
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('12 Mei 2024, 14:32 WIB'), findsOneWidget);

      // Branch Info & CTA
      expect(find.text('Toko Buku Budi Cikini'), findsOneWidget);
      expect(find.text('Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat 10330'),
          findsOneWidget);
      expect(find.text('Lihat QR Pickup'), findsOneWidget);

      // Timeline Stepper
      expect(find.text('Status Perjalanan Buku'), findsOneWidget);
      expect(find.text('Diperbarui 16:15'), findsOneWidget);
      expect(find.text('Pesanan Dibuat'), findsOneWidget);
      expect(find.text('Pembayaran Lunas'), findsOneWidget);
      expect(find.text('Diproses Kurator Buku'), findsOneWidget);
      expect(find.text('Siap Diambil di Toko'), findsOneWidget);

      // Book Items
      expect(find.text('Rincian Buku'), findsOneWidget);
      expect(find.text('2 Item'), findsOneWidget);
      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.text('Filosofi Teras'), findsOneWidget);

      // Payment Summary
      expect(find.text('Ringkasan Pembayaran'), findsOneWidget);
      expect(find.text('QRIS Lunas'), findsOneWidget);
      expect(find.text('Subtotal Buku (2 item)'), findsOneWidget);
      expect(find.text('Voucher (BUDISANTAI)'), findsOneWidget);
      expect(find.text('-Rp15.000'), findsOneWidget);
      expect(find.text('Pengambilan di Toko (Self-Pickup)'), findsOneWidget);
      expect(find.text('Gratis'), findsOneWidget);
      expect(find.text('Biaya Layanan Aplikasi'), findsOneWidget);
      expect(find.text('Rp1.000'), findsOneWidget);
      expect(find.text('Total Pembayaran'), findsOneWidget);
      expect(find.text('Metode: QRIS BCA'), findsOneWidget);
      expect(find.text('Rp181.000'), findsOneWidget);

      // Assistance
      expect(find.text('Butuh bantuan pesanan?'), findsOneWidget);
      expect(find.text('Pustakawan kami siap membantu'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
    });
  });
}
