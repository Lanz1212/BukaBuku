import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/profile/screens/profile_screen.dart';
import 'package:buka_buku/features/profile/screens/edit_profile_screen.dart';
import 'package:buka_buku/features/profile/screens/shipping_address_screen.dart';
import 'package:buka_buku/features/profile/models/user_profile.dart';

void main() {
  group('Profile Feature UI Tests', () {
    testWidgets('ProfileScreen renders all header, stats, and menu sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify removed items are NOT present
      expect(find.text('Pembaca Terdaftar'), findsNothing);
      expect(find.text('Voucher Aktif'), findsNothing);
      expect(find.text('Voucher & Kupon'), findsNothing);
      expect(find.text('Panel Admin Toko'), findsNothing);

      // Check stats counters
      expect(find.text('Pesanan'), findsWidgets);
      expect(find.text('Buku Favorit'), findsWidgets);

      // Check quote
      expect(
        find.textContaining('Membaca adalah jembatan menuju peradaban'),
        findsOneWidget,
      );

      // Check sections
      expect(find.text('Aktivitas Saya'), findsOneWidget);
      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Tentang & Bantuan'), findsOneWidget);

      // Check action buttons
      expect(find.text('Keluar dari Akun'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders fields and updates profile on save',
        (WidgetTester tester) async {
      UserProfile? returnedUser;
      const testUser = UserProfile(
        id: 'u_123',
        name: 'Andi Pembaca',
        email: 'andi@gmail.com',
        phone: '08123456789',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    returnedUser = await Navigator.push<UserProfile>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(user: testUser),
                      ),
                    );
                  },
                  child: const Text('Open Edit'),
                ),
              );
            },
          ),
        ),
      );

      // Open Edit Profile
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Verify form elements exist
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Alamat Email'), findsOneWidget);
      expect(find.text('Terverifikasi'), findsOneWidget);
      expect(find.text('Nomor Handphone'), findsOneWidget);
      // Tanggal Lahir should NOT exist
      expect(find.text('Tanggal Lahir'), findsNothing);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Edit name field
      final nameField = find.widgetWithText(TextFormField, 'Andi Pembaca');
      await tester.enterText(nameField, 'Andi Perkasa');
      await tester.pumpAndSettle();

      // Tap Simpan Perubahan
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verify result was returned
      expect(returnedUser, isNotNull);
      expect(returnedUser!.name, 'Andi Perkasa');
    });

    testWidgets('ShippingAddressScreen renders header and add button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ShippingAddressScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('Daftar Alamat Saya'), findsOneWidget);
      expect(find.text('BUKU & PENGIRIMAN'), findsOneWidget);
      expect(find.text('Tambah Alamat Baru'), findsOneWidget);
    });
  });
}
