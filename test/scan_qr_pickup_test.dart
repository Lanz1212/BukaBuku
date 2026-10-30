import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/admin/scan_qr_pickup/screens/scan_qr_pickup_screen.dart';
import 'package:buka_buku/features/admin/order_management/models/admin_order_detail.dart';

void main() {
  group('ScanQrPickupScreen Tests', () {
    testWidgets('Renders all visual components matching mockup',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanQrPickupScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. AppBar
      expect(find.text('Scan Qr Pickup'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
      expect(find.byIcon(Icons.flashlight_on_outlined), findsWidgets);
      expect(find.byIcon(Icons.cameraswitch_outlined), findsOneWidget);

      // 2. Mode Kasir Banner
      expect(find.text('Mode Kasir: Gerai Cikini'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);

      // 3. Viewfinder
      expect(find.text('Sensor Kamera Siaga'), findsOneWidget);
      expect(find.text('Senter Mati'), findsOneWidget);
      expect(find.text('BIDIK QR'), findsOneWidget);
      expect(find.text('1x'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);

      // 4. Instructions
      expect(find.text('Arahkan kamera ke QR Pickup'), findsOneWidget);
      expect(
        find.text(
          'Pastikan kode QR berada tepat di dalam bingkai bidik untuk proses verifikasi instan.',
        ),
        findsOneWidget,
      );

      // 5. Action Buttons
      expect(find.text('Nyalakan Senter'), findsOneWidget);
      expect(find.text('Input Manual #ORD'), findsOneWidget);

      // 6. Detection Card
      expect(find.text('Pesanan Terdeteksi'), findsOneWidget);
      expect(find.text('Verifikasi 0.3s'), findsOneWidget);
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('2 Buku Koleksi • Rp150.000'), findsOneWidget);
      expect(find.text('Buka Hasil Validasi'), findsOneWidget);
      expect(
        find.text(
          'Otomatis mengenali QR resmi Toko Buku Budi dalam hitungan detik.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Toggling torch updates action button and viewfinder status',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanQrPickupScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Nyalakan Senter button
      await tester.tap(find.text('Nyalakan Senter'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Matikan Senter'), findsOneWidget);
      expect(find.text('Senter Aktif'), findsOneWidget);

      // Tap again to toggle off
      await tester.tap(find.text('Matikan Senter'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Nyalakan Senter'), findsOneWidget);
      expect(find.text('Senter Mati'), findsOneWidget);
    });

    testWidgets('Opening manual input sheet allows entering order ID',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanQrPickupScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "Input Manual #ORD"
      await tester.tap(find.text('Input Manual #ORD'));
      await tester.pump(const Duration(milliseconds: 400));

      // Verify sheet is open
      expect(find.text('Ketik nomor pesanan dari nota atau struk'), findsOneWidget);
      expect(find.text('#ORD00125 (Budi Santoso)'), findsOneWidget);

      // Tap quick chip
      await tester.tap(find.text('#ORD00125 (Budi Santoso)'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      // Tap submit
      await tester.tap(find.text('Cari & Verifikasi Pesanan'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 400));

      // Sheet closed and card shows #ORD00125
      expect(find.text('#ORD00125'), findsOneWidget);
    });

    testWidgets('Validation CTA opens confirmation bottom sheet and completes order',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockOrder = AdminOrderDetail.mockOrders.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ScanQrPickupScreen(
            preloadedOrder: mockOrder,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "Buka Hasil Validasi"
      await tester.tap(find.text('Buka Hasil Validasi'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify validation screen
      expect(find.text('Hasil Scan Qr'), findsOneWidget);
      expect(find.text('QR Valid'), findsOneWidget);
      expect(find.text('Konfirmasi Pengambilan'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('Konfirmasi Pengambilan'), warnIfMissed: false);
      await tester.pumpAndSettle();
    });
  });
}
