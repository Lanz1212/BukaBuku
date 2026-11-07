import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/profile/screens/help_center_screen.dart';
import 'package:buka_buku/features/profile/screens/about_screen.dart';
import 'package:buka_buku/features/profile/screens/privacy_policy_screen.dart';

void main() {
  group('About & Help Center Feature Tests', () {
    testWidgets('HelpCenterScreen renders hero, categories, and filters search',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HelpCenterScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ada yang bisa kami bantu?'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('Pembayaran'), findsOneWidget);
      expect(find.text('WhatsApp Buka Buku Care'), findsOneWidget);

      // Search functionality
      await tester.enterText(find.byType(TextField), 'QRIS');
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Apakah pembayaran dengan QRIS diverifikasi otomatis?'),
        findsOneWidget,
      );
    });

    testWidgets('AboutScreen renders bookstore story and store address',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Menemani Pembaca Indonesia Sejak 1982'), findsOneWidget);
      expect(find.text('Kisah Kami'), findsOneWidget);
      expect(find.text('Komitmen Kami'), findsOneWidget);
      expect(find.text('Gerai Utama Buka Buku'), findsOneWidget);
      expect(find.text('Salin Alamat'), findsOneWidget);
    });

    testWidgets('PrivacyPolicyScreen renders policy clauses and last updated info',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Perlindungan Data & Layanan'), findsOneWidget);
      expect(find.text('Ketentuan Akun & Pendaftaran'), findsOneWidget);
      expect(find.text('Pemesanan & Pembayaran'), findsOneWidget);
      expect(find.text('Kebijakan Privasi & Keamanan Data'), findsOneWidget);
    });
  });
}
