import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/admin/book_management/widgets/book_form_cover_upload.dart';
import 'package:buka_buku/features/book_detail/models/book_detail.dart';
import 'package:buka_buku/features/search/models/book_search_item.dart';

void main() {
  group('Book Cover Upload Feature Tests', () {
    test('BookDetail.empty has safe default values and empty coverUrl', () {
      const empty = BookDetail.empty;
      expect(empty.id, isEmpty);
      expect(empty.coverUrl, isEmpty);
      expect(empty.stockStatus, StockStatus.outOfStock);
    });

    testWidgets('BookFormCoverUpload displays upload placeholder when no cover',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookFormCoverUpload(
              initialCoverUrl: null,
              pickedFile: null,
              onFileSelected: (_) {},
              onRemoveCover: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cover Buku'), findsOneWidget);
      expect(find.text('Unggah Foto Cover Buku'), findsOneWidget);
      expect(find.text('Pilih Foto dari HP'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });

    testWidgets('BookFormCoverUpload displays change and remove buttons when cover url exists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookFormCoverUpload(
              initialCoverUrl: 'https://example.com/cover.jpg',
              pickedFile: null,
              onFileSelected: (_) {},
              onRemoveCover: () {},
            ),
          ),
        ),
      );

      expect(find.text('Ganti Foto Sampul'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('BookFormCoverUpload tapping upload opens source bottomsheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookFormCoverUpload(
              initialCoverUrl: null,
              pickedFile: null,
              onFileSelected: (_) {},
              onRemoveCover: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pilih Foto dari HP'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Sumber Foto Sampul'), findsOneWidget);
      expect(find.text('Galeri HP'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
    });
  });
}
