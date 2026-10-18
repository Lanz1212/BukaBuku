import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/favorite/screens/favorite_screen.dart';
import 'package:buka_buku/features/favorite/models/favorite_item.dart';

// Minimal 1x1 transparent PNG for mocking NetworkImage
final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('FavoriteScreen renders list items and demo switcher correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Buku Favorit'), findsWidgets);
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('James Clear'), findsOneWidget);
    expect(find.text('Filosofi Teras'), findsOneWidget);
    expect(find.text('Laut Bercerita'), findsOneWidget);
    expect(find.text('Sapiens'), findsOneWidget);

    // Verify badges and out-of-stock indicators
    expect(find.text('Bestseller'), findsOneWidget);
    expect(find.text('Edisi Baru'), findsOneWidget);
    expect(find.text('Terbatas'), findsOneWidget);
    expect(find.text('Habis'), findsOneWidget);

    // Switch to Empty State demo tab
    await tester.tap(find.text('Tampilan Kosong (Demo)'));
    await tester.pumpAndSettle();

    // Verify empty state content
    expect(find.text('Belum ada buku favorit.'), findsOneWidget);
    expect(find.text('Mulai Cari Buku Favorit'), findsOneWidget);

    // Switch back to Favorite list
    await tester.tap(find.textContaining('Daftar Favorit'));
    await tester.pumpAndSettle();

    expect(find.text('Atomic Habits'), findsOneWidget);
  });

  testWidgets('FavoriteScreen handles add-to-cart and item removal with undo', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FavoriteScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Add to cart on Atomic Habits
    final addToCartButtons = find.byIcon(Icons.shopping_bag_outlined);
    expect(addToCartButtons, findsWidgets);
    await tester.tap(addToCartButtons.first);
    await tester.pump();

    expect(find.textContaining('dimasukkan ke keranjang'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));

    // Tap Favorite Heart to remove first item
    final heartButtons = find.byIcon(Icons.favorite);
    expect(heartButtons, findsWidgets);
    await tester.tap(heartButtons.first);
    await tester.pump();

    // SnackBar with undo action should appear
    expect(find.textContaining('dihapus dari favorit'), findsOneWidget);
    expect(find.text('BATAL'), findsOneWidget);

    // Tap Undo
    await tester.tap(find.text('BATAL'));
    await tester.pumpAndSettle();

    // Atomic Habits should be back
    expect(find.text('Atomic Habits'), findsOneWidget);
  });
}
