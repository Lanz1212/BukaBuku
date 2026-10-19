import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/payment/screens/payment_method_screen.dart';
import 'package:buka_buku/features/payment/screens/qris_payment_screen.dart';
import 'package:buka_buku/features/payment/widgets/qris_code_card.dart';
import 'package:buka_buku/features/payment/widgets/qris_countdown_banner.dart';
import 'package:buka_buku/features/payment/widgets/qris_guide_accordion.dart';

void main() {
  group('Payment UI Tests', () {
    testWidgets(
        'PaymentMethodScreen renders header, order banner, options, and bottom bar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodScreen(
            orderId: '#ORD00125',
            totalAmount: 181000,
            bookCount: 2,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check App Bar Title
      expect(find.text('Metode Pembayaran'), findsOneWidget);

      // Check Order Summary
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Rp181.000'), findsOneWidget);
      expect(find.text('2 buku terkurasi • Termasuk pajak'), findsOneWidget);

      // Check Category Titles
      expect(find.text('Pembayaran Instan & Digital'), findsOneWidget);
      expect(find.text('Bebas Biaya Admin'), findsOneWidget);
      expect(find.text('Pembayaran di Tempat'), findsOneWidget);

      // Check Payment Methods (QRIS appears both in option tile and in bottom bar summary)
      expect(find.text('QRIS (Semua Pembayaran)'), findsNWidgets(2));
      expect(find.text('Virtual Account Bank'), findsOneWidget);
      expect(find.text('Dompet Digital (E-Wallet)'), findsOneWidget);
      expect(find.text('Cash Saat Pengambilan'), findsOneWidget);

      // Check Badges
      expect(find.text('Paling Cepat'), findsOneWidget);
      expect(find.text('Ambil di Toko'), findsOneWidget);

      // Check Bottom Bar
      expect(find.text('Metode dipilih:'), findsOneWidget);
      expect(find.text('Lanjutkan Pembayaran'), findsOneWidget);
    });

    testWidgets('Tapping Lanjutkan Pembayaran with QRIS opens QrisPaymentScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PaymentMethodScreen(
            orderId: '#ORD00125',
            totalAmount: 181000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Lanjutkan Pembayaran button
      final continueButton = find.text('Lanjutkan Pembayaran');
      expect(continueButton, findsOneWidget);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // Should now be on QrisPaymentScreen
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('1. Menunggu'), findsOneWidget);
      expect(find.text('Toko Buku Budi Cikini'), findsOneWidget);
      expect(find.text('NMID: ID1020038891002'), findsOneWidget);
    });

    testWidgets('QrisPaymentScreen supports simulation state switching',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: QrisPaymentScreen(
            orderId: '#ORD00125',
            totalAmount: 181000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Initial Pending State widgets
      expect(find.byType(QrisCountdownBanner), findsOneWidget);
      expect(find.byType(QrisCodeCard), findsOneWidget);
      expect(find.byType(QrisGuideAccordion), findsOneWidget);
      expect(find.text('Saya Sudah Membayar'), findsOneWidget);
      expect(find.text('Batalkan Pembayaran'), findsOneWidget);

      // Switch to 2. Berhasil via top simulation bar
      await tester.tap(find.text('2. Berhasil'));
      await tester.pumpAndSettle();
      expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
      expect(find.text('Lihat Struk Pesanan'), findsOneWidget);

      // Switch to 3. Gagal via top simulation bar
      await tester.tap(find.text('3. Gagal'));
      await tester.pumpAndSettle();
      expect(find.text('Pembayaran Gagal'), findsOneWidget);
      expect(find.text('Coba Bayar Ulang'), findsOneWidget);

      // Switch to 4. Kedaluwarsa via top simulation bar
      await tester.tap(find.text('4. Kedaluwarsa'));
      await tester.pumpAndSettle();
      expect(find.text('Kode QR Kedaluwarsa'), findsOneWidget);
      expect(find.text('Perbarui Kode QR'), findsOneWidget);

      // Switch back to 1. Menunggu via top simulation bar
      await tester.tap(find.text('1. Menunggu'));
      await tester.pumpAndSettle();
      expect(find.byType(QrisCodeCard), findsOneWidget);
      expect(find.text('Saya Sudah Membayar'), findsOneWidget);

      // Tap Saya Sudah Membayar button -> should switch to success
      await tester.tap(find.text('Saya Sudah Membayar'));
      await tester.pumpAndSettle();
      expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
    });
  });
}
