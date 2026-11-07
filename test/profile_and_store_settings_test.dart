import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/profile/models/user_profile.dart';
import 'package:buka_buku/features/profile/models/shipping_address.dart';
import 'package:buka_buku/features/profile/services/profile_service.dart';
import 'package:buka_buku/features/admin/store_settings/models/store_settings_model.dart';
import 'package:buka_buku/features/admin/store_settings/services/store_settings_service.dart';
import 'package:buka_buku/features/admin/store_settings/screens/store_settings_screen.dart';

void main() {
  group('Supabase Profile & Store Settings Unit & UI Tests', () {
    test('UserProfile serializes and deserializes from Supabase map correctly', () {
      final map = {
        'id': 'user_999',
        'full_name': 'Rendra Pratama',
        'email': 'rendra@tokobukubudi.id',
        'phone': '08123456789',
        'avatar_url': 'assets/images/Profile.png',
      };

      final profile = UserProfile.fromSupabase(map, orderCount: 7);

      expect(profile.id, 'user_999');
      expect(profile.name, 'Rendra Pratama');
      expect(profile.email, 'rendra@tokobukubudi.id');
      expect(profile.phone, '08123456789');
      expect(profile.orderCount, 7);

      final outMap = profile.toSupabaseMap();
      expect(outMap['full_name'], 'Rendra Pratama');
      expect(outMap['phone'], '08123456789');
    });

    test('ShippingAddress serializes and deserializes to map correctly', () {
      const address = ShippingAddress(
        id: 'addr_100',
        recipientName: 'Budi Santoso',
        phoneNumber: '081122334455',
        label: 'Kantor',
        fullAddress: 'Jl. Sudirman No. 10',
        courierNote: 'Lantai 5',
        isPrimary: true,
        isGeotagVerified: true,
      );

      final map = address.toMap();
      expect(map['recipientName'], 'Budi Santoso');
      expect(map['label'], 'Kantor');
      expect(map['isPrimary'], true);

      final restored = ShippingAddress.fromMap(map);
      expect(restored.id, 'addr_100');
      expect(restored.recipientName, 'Budi Santoso');
      expect(restored.fullAddress, 'Jl. Sudirman No. 10');
      expect(restored.courierNote, 'Lantai 5');
      expect(restored.isPrimary, true);
    });

    test('StoreSettingsModel serializes and deserializes from Supabase map correctly', () {
      final map = {
        'store_name': 'Toko Buku Budi Cikini',
        'branch_name': 'Cabang Menteng',
        'address': 'Jl. Cikini Raya 45',
        'district': 'Menteng',
        'city': 'Jakarta Pusat',
        'postal_code': '10330',
        'latitude': -6.1912,
        'longitude': 106.8404,
        'phone_number': '021-31908822',
        'whatsapp_number': '081299887711',
        'open_time': '09:00 WIB',
        'close_time': '20:00 WIB',
        'operating_days': 'Senin - Sabtu',
        'description': 'Toko buku ramah pembaca',
        'max_pickup_hours': 72,
        'photo_path': 'assets/images/store.jpg',
      };

      final settings = StoreSettingsModel.fromSupabase(map);
      expect(settings.storeName, 'Toko Buku Budi Cikini');
      expect(settings.branchName, 'Cabang Menteng');
      expect(settings.openTime, '09:00 WIB');
      expect(settings.closeTime, '20:00 WIB');
      expect(settings.maxPickupHours, 72);

      final outMap = settings.toSupabaseMap();
      expect(outMap['store_name'], 'Toko Buku Budi Cikini');
      expect(outMap['open_time'], '09:00 WIB');
      expect(outMap['close_time'], '20:00 WIB');
      expect(outMap['max_pickup_hours'], 72);
    });

    test('ProfileService & StoreSettingsService safely fallback offline', () async {
      final profile = await ProfileService.fetchCurrentUserProfile();
      expect(profile, isNotNull);

      final addresses = await ProfileService.fetchUserAddresses();
      expect(addresses, isA<List<ShippingAddress>>());

      final settings = await StoreSettingsService.fetchStoreSettings();
      expect(settings.storeName, isNotEmpty);
      expect(settings.openTime, isNotEmpty);
    });

    testWidgets('StoreSettingsScreen renders form fields and can be submitted',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: StoreSettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check form headers
      expect(find.text('PROFIL GERAI FISIK'), findsOneWidget);
      expect(find.text('Logo & Identitas Visual'), findsOneWidget);
      expect(find.text('Nama Toko Resmi'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Tap Simpan Perubahan
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('Perubahan profil gerai berhasil disimpan ke database!'), findsOneWidget);
    });
  });
}
