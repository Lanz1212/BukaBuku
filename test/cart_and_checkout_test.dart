import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buka_buku/features/cart/models/cart_item.dart';
import 'package:buka_buku/features/cart/screens/cart_screen.dart';
import 'package:buka_buku/features/checkout/screens/checkout_screen.dart';

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
    return Stream<List<int>>.value(_transparentPng).listen(
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

  testWidgets('CartScreen renders correctly and toggles demo states',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CartScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and items
    expect(find.text('Keranjang'), findsWidgets);
    expect(find.text('Toko Budi Cikini'), findsOneWidget);
    expect(find.text('Atomic Habits'), findsOneWidget);
    expect(find.text('Filosofi Teras (Edisi Baru)'), findsOneWidget);
    expect(find.text('Rp183.000'), findsWidgets);
    expect(find.text('Checkout (2)'), findsOneWidget);

    // Toggle Empty State demo tab
    await tester.tap(find.text('Lihat Empty State'));
    await tester.pumpAndSettle();

    expect(find.text('Keranjangmu masih kosong.'), findsOneWidget);
    expect(find.text('Mulai Belanja'), findsOneWidget);

    // Switch back to cart
    await tester.tap(find.text('Mulai Belanja'));
    await tester.pumpAndSettle();

    expect(find.text('Atomic Habits'), findsOneWidget);
  });

  testWidgets('CheckoutScreen renders and handles fulfillment mode toggles',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutScreen(
          checkoutItems: CartItem.defaultCartItems,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and sections
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Selesaikan Pesanan'), findsOneWidget);
    expect(find.text('Ringkasan Pesanan'), findsOneWidget);
    expect(find.text('Metode Pengambilan'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
    expect(find.text('Kurir Toko Ekspres'), findsOneWidget);
    expect(find.text('QRIS Instant'), findsOneWidget);
    expect(find.text('Ringkasan Pembayaran'), findsOneWidget);
    expect(find.text('Rp196.000'), findsWidgets);
    expect(find.text('Buat Pesanan'), findsOneWidget);

    // Toggle to Ambil di Toko
    await tester.tap(find.text('Ambil di Toko').first);
    await tester.pumpAndSettle();

    // Verify free shipping and updated total Rp184.000
    expect(find.text('Bebas Ongkir'), findsWidgets);
    expect(find.text('Toko Buku Budi (Pusat Cikini)'), findsOneWidget);
    expect(find.text('Rp184.000'), findsWidgets);
  });
}
