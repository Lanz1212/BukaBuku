import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/book_detail/screens/book_detail_screen.dart';

void main() {
  testWidgets('BookDetailScreen renders Atomic Habits detail correctly',
      (WidgetTester tester) async {
    // Set a phone-sized screen surface
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BookDetailScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify key titles & sections
    expect(find.text('Detail Buku'), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Karya James Clear'), findsOneWidget);
    expect(find.text('100% Original & Bergaransi Toko Buku Budi'), findsOneWidget);
    expect(find.text('SPESIFIKASI BUKU'), findsOneWidget);
    expect(find.text('DESKRIPSI BUKU'), findsOneWidget);
    expect(find.text('ULASAN PEMBACA'), findsOneWidget);
    expect(find.textContaining('Beli Sekarang'), findsOneWidget);
  });
}
