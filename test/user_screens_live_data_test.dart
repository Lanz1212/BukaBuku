import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/book_detail/screens/book_detail_screen.dart';
import 'package:buka_buku/features/book_detail/models/book_detail.dart';
import 'package:buka_buku/features/admin/book_management/models/admin_book_item.dart';
import 'package:buka_buku/features/search/screens/search_screen.dart';
import 'package:buka_buku/features/category/screens/category_screen.dart';
import 'package:buka_buku/features/home/home_screen.dart';

void main() {
  group('Live Data & User Screen Tests', () {
    testWidgets('BookDetailScreen does NOT display discounts or strikethrough prices',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const testBook = AdminBookItem(
        id: 'B002',
        title: 'Filosofi Teras',
        author: 'Henry Manampiring',
        isbn: '978-602-412-518-9',
        price: 98000,
        stock: 3,
        rackLocation: 'Rak B1',
        status: AdminBookStatus.menipis,
        isActive: true,
        category: 'Non-Fiksi',
        coverUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailScreen(
            bookDetail: BookDetail.fromAdminBookItem(testBook),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filosofi Teras'), findsOneWidget);
      expect(find.text('Karya Henry Manampiring'), findsOneWidget);
      expect(find.text('Rp 98.000'), findsOneWidget);

      // Verify no discount badges or fake strikethrough text exist
      expect(find.textContaining('-10%'), findsNothing);
      expect(find.textContaining('-19%'), findsNothing);
      expect(find.textContaining('-20%'), findsNothing);
      expect(find.textContaining('10%'), findsNothing);
    });

    testWidgets('SearchScreen does not have UX dev mode toggle and starts clean',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SearchScreen(),
        ),
      );
      await tester.pump();

      // Verify dev preview buttons are removed
      expect(find.text('Pratinjau Kosong'), findsNothing);
      expect(find.text('Hasil Ditemukan (12)'), findsNothing);
    });

    testWidgets('CategoryScreen renders UI correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('Kategori Buku'), findsOneWidget);
      expect(find.text('Koleksi Terkurasi'), findsOneWidget);
    });

    testWidgets('HomeScreen renders with no discount promo banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pump();

      // No promo banner with 20% discount
      expect(find.text('Diskon 20%'), findsNothing);
      expect(find.text('Ambil Promo'), findsNothing);

      // Category chip 'Semua' should be present
      expect(find.text('Semua'), findsOneWidget);
    });
  });
}

