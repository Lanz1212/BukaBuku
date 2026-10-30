import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/admin/shared/screens/admin_main_screen.dart';
import 'package:buka_buku/features/admin/stock_management/screens/stock_management_screen.dart';
import 'package:buka_buku/features/admin/category_management/screens/category_management_screen.dart';
import 'package:buka_buku/features/admin/order_management/screens/order_management_screen.dart';

void main() {
  group('Admin Pages Tests', () {
    testWidgets('StockManagementScreen renders elements and opens adjust modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StockManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Summary
      expect(find.text('Manajemen Stok Buku'), findsOneWidget);
      expect(find.text('Gerai Utama Toko Budi'), findsOneWidget);
      expect(find.text('Total Judul'), findsOneWidget);
      expect(find.text('Stok Menipis'), findsWidgets);

      // Verify Books list
      expect(find.text('Atomic Habits'), findsOneWidget);
      expect(find.text('Filosofi Teras'), findsOneWidget);

      // Tap "Atur Stok" on first book
      final adjustButtons = find.text('Atur Stok');
      expect(adjustButtons, findsWidgets);
      await tester.tap(adjustButtons.first);
      await tester.pumpAndSettle();

      // Verify Adjust Modal opened
      expect(find.textContaining('Atur Stok:'), findsOneWidget);
      expect(find.text('Jenis Perubahan'), findsOneWidget);
      expect(find.text('Tambah Stok Masuk (+)'), findsOneWidget);
      expect(find.text('Simpan Perubahan Stok'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
    });

    testWidgets('CategoryManagementScreen renders categories and opens add modal',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryManagementScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Kategori Buku'), findsOneWidget);
      expect(find.text('Klasifikasi & Penempatan Rak Toko'), findsOneWidget);

      // Verify Categories
      expect(find.text('Novel & Fiksi'), findsOneWidget);
      expect(find.text('NVL-01'), findsOneWidget);
      expect(find.text('Komik & Manga'), findsOneWidget);

      // Verify Add button and tap it
      final addButton = find.text('Tambah Kategori Baru');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify Form modal opened
      expect(find.text('Nama Kategori'), findsOneWidget);
      expect(find.text('Kode Kategori'), findsOneWidget);
      expect(find.text('Tambahkan Kategori'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
    });

    testWidgets('OrderManagementScreen renders orders and handles actions',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Pesanan Masuk'), findsOneWidget);
      expect(find.textContaining('Perlu Aksi'), findsOneWidget);

      // Verify Order items
      expect(find.text('#ORD00125'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);

      // Tap Detail to navigate to AdminOrderDetailScreen
      final detailButtons = find.text('Detail');
      expect(detailButtons, findsWidgets);
      await tester.tap(detailButtons.first);
      await tester.pumpAndSettle();

      // AdminOrderDetailScreen should be open
      expect(find.text('Detail Pesanan Admin'), findsOneWidget);
      expect(find.text('Informasi Pelanggan'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('AdminMainScreen bottom nav switches between 5 tabs smoothly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminMainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 0: Dashboard
      expect(find.text('Dashboard'), findsWidgets);

      // Switch to Tab 2: Stok
      await tester.tap(find.text('Stok'));
      await tester.pumpAndSettle();
      expect(find.text('Manajemen Stok Buku'), findsOneWidget);

      // Switch to Tab 3: Pesanan
      await tester.tap(find.text('Pesanan'));
      await tester.pumpAndSettle();
      expect(find.text('Pesanan Masuk'), findsWidgets);

      // Switch to Tab 4: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Budi Pratama'), findsOneWidget);
      expect(find.text('Owner / Super Admin'), findsOneWidget);
      expect(find.text('Pengaturan Toko'), findsOneWidget);

      // Tap on Pengaturan Toko to open StoreSettingsScreen
      await tester.tap(find.text('Pengaturan Toko'));
      await tester.pumpAndSettle();

      // Verify StoreSettingsScreen opened
      expect(find.text('PROFIL GERAI FISIK'), findsOneWidget);
      expect(find.text('Logo & Identitas Visual'), findsOneWidget);
      expect(find.text('Nama Toko Resmi'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);

      // Pop back to AdminProfileScreen
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.text('Budi Pratama'), findsOneWidget);
    });
  });
}
