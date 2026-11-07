import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cart_service.dart';
import '../../features/admin/order_management/models/admin_order_detail.dart';
import '../../features/order/models/order_model.dart';
import '../../features/order/models/order_item_model.dart';

class OrderService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── READ: Ambil Semua Pesanan Masuk (untuk Admin) ──────────────────────────
  static Future<List<AdminOrderDetail>> fetchAdminOrders({
    String? statusQuery,
    String? searchQuery,
    int? limit,
  }) async {
    try {
      var query = _client.from('orders').select('*, order_items(*)');

      if (statusQuery != null &&
          statusQuery.isNotEmpty &&
          statusQuery != 'semua') {
        query = query.eq('status', statusQuery);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or(
          'id.ilike.%$q%,customer_name.ilike.%$q%,customer_phone.ilike.%$q%',
        );
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 100);

      final list = response as List<dynamic>;
      return list
          .map((row) => AdminOrderDetail.fromMap(
                row as Map<String, dynamic>,
                row['order_items'] as List<dynamic>?,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching admin orders: $e');
      return [];
    }
  }

  // ─── READ: Ambil Detail Pesanan Tunggal ─────────────────────────────────────
  static Future<AdminOrderDetail?> fetchOrderById(String orderId) async {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', cleanId)
          .maybeSingle();

      if (response == null) return null;
      return AdminOrderDetail.fromMap(
        response,
        response['order_items'] as List<dynamic>?,
      );
    } catch (e) {
      debugPrint('Error fetching order by ID: $e');
      return null;
    }
  }

  // ─── READ: Cari Pesanan Berdasarkan QR Code / Order ID / Pickup Code ─────────
  static Future<AdminOrderDetail?> fetchOrderByCodeOrId(String rawCode) async {
    try {
      final code = rawCode.replaceAll('#', '').trim();
      if (code.isEmpty) return null;

      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .or('id.eq.$code,qr_code.eq.$code,pickup_code.eq.$code')
          .maybeSingle();

      if (response == null) return null;
      return AdminOrderDetail.fromMap(
        response,
        response['order_items'] as List<dynamic>?,
      );
    } catch (e) {
      debugPrint('Error fetching order by code or id: $e');
      // Fallback for mock/test environment when Supabase is uninitialized
      try {
        final code = rawCode.replaceAll('#', '').toUpperCase().trim();
        return AdminOrderDetail.mockOrders.firstWhere(
          (o) =>
              o.orderId.toUpperCase() == code ||
              (o.pickupCode ?? '').toUpperCase() == code ||
              (o.qrCode ?? '').toUpperCase() == code,
          orElse: () => AdminOrderDetail.mockOrders.first,
        );
      } catch (_) {
        return null;
      }
    }
  }

  static String _formatRupiah(int amount) =>
      'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  // ─── HELPER: Map Single Database Row to OrderModel ─────────────────────────
  static OrderModel mapRowToOrderModel(Map<String, dynamic> orderMap) {
    final rawItems = orderMap['order_items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      final iMap = item as Map<String, dynamic>;
      final price = (iMap['price'] as num?)?.toInt() ?? 0;
      final qty = (iMap['quantity'] as num?)?.toInt() ?? 1;
      final sub = price * qty;
      return OrderItemModel(
        id: 'item-${iMap['id'] ?? ''}',
        bookId: iMap['book_id'] as String?,
        title: iMap['title'] as String? ?? 'Buku',
        author: iMap['author'] as String? ?? '',
        coverUrl: iMap['image_url'] as String? ?? '',
        quantity: qty,
        pricePerUnit: _formatRupiah(price),
        pricePerUnitValue: price,
        subtotal: _formatRupiah(sub),
        subtotalValue: sub,
      );
    }).toList();

    final statusStr = orderMap['status'] as String? ?? 'baru';
    OrderStatus status = OrderStatus.processing;
    if (statusStr == 'siapDiambil') {
      status = OrderStatus.readyPickup;
    } else if (statusStr == 'dalamPengiriman') {
      status = OrderStatus.shipping;
    } else if (statusStr == 'selesai') {
      status = OrderStatus.completed;
    }

    final isDelivery = (orderMap['delivery_type'] as String? ?? '')
        .toLowerCase()
        .contains('kurir');
    final totalPrice = (orderMap['total_price'] as num?)?.toInt() ?? 0;
    final totalStr = _formatRupiah(totalPrice);

    final itemsSubtotalValue =
        items.fold(0, (sum, i) => sum + i.subtotalValue);
    final itemsSubtotalStr = _formatRupiah(itemsSubtotalValue);

    final firstItem = items.isNotEmpty ? items.first : null;
    final String summaryTitle;
    final String summarySubtitle;
    if (items.length > 1) {
      summaryTitle =
          '${firstItem?.title ?? "Buku"} & ${items.length - 1} Buku Lainnya';
      final totalBooks = items.fold(0, (sum, i) => sum + i.quantity);
      summarySubtitle =
          '${firstItem?.author ?? "Penulis"}, dkk • $totalBooks Buku';
    } else if (firstItem != null) {
      summaryTitle = firstItem.title;
      summarySubtitle = '${firstItem.author} • ${firstItem.quantity}x';
    } else {
      summaryTitle = 'Pesanan Buku';
      summarySubtitle = '';
    }

    final totalBooksCount = items.fold(0, (sum, i) => sum + i.quantity);
    final summaryItemCountLabel = items.length > 1
        ? '${items.length} Judul ($totalBooksCount Buku)'
        : '$totalBooksCount Buku';

    String dateTimeDisplay = 'Hari ini';
    String orderDateExact = '';
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    if (orderMap['created_at'] != null) {
      final parsedDate =
          DateTime.tryParse(orderMap['created_at'].toString())?.toLocal();
      if (parsedDate != null) {
        final day = parsedDate.day.toString().padLeft(2, '0');
        final month = monthNames[parsedDate.month - 1];
        final year = parsedDate.year;
        final hour = parsedDate.hour.toString().padLeft(2, '0');
        final minute = parsedDate.minute.toString().padLeft(2, '0');
        dateTimeDisplay = '$day $month $year • $hour:$minute WIB';
        orderDateExact = '$day $month $year, $hour:$minute WIB';
      }
    }

    String? completionDate = orderMap['completion_date'] as String?;
    if (status == OrderStatus.completed) {
      if (completionDate == null && orderMap['pickup_confirmed_at'] != null) {
        final confirmedDate =
            DateTime.tryParse(orderMap['pickup_confirmed_at'].toString())?.toLocal();
        if (confirmedDate != null) {
          final day = confirmedDate.day.toString().padLeft(2, '0');
          final month = monthNames[confirmedDate.month - 1];
          final year = confirmedDate.year;
          final hour = confirmedDate.hour.toString().padLeft(2, '0');
          final minute = confirmedDate.minute.toString().padLeft(2, '0');
          completionDate = '$day $month $year, $hour:$minute WIB';
        }
      }
      completionDate ??= orderDateExact.isNotEmpty ? orderDateExact : dateTimeDisplay;
    }

    final List<OrderTimelineStepModel> timeline;
    if (status == OrderStatus.completed) {
      timeline = [
        OrderTimelineStepModel(
          title: 'Pesanan Dibuat',
          time: dateTimeDisplay,
          description: 'Pesanan berhasil tercatat di sistem Buka Buku.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Pembayaran Lunas',
          time: 'Terverifikasi',
          description: 'Terverifikasi otomatis via QRIS.',
          isDone: true,
        ),
        OrderTimelineStepModel(
          title: isDelivery ? 'Buku Dikirimkan' : 'Siap Diambil di Toko',
          time: 'Selesai',
          description: isDelivery
              ? 'Buku telah dikirimkan oleh kurir.'
              : 'Buku disiapkan di kasir Toko Buka Buku.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Pesanan Selesai',
          time: 'Selesai',
          description: 'Buku telah diterima oleh pembaca.',
          isDone: true,
        ),
      ];
    } else if (status == OrderStatus.readyPickup) {
      timeline = [
        OrderTimelineStepModel(
          title: 'Pesanan Dibuat',
          time: dateTimeDisplay,
          description: 'Pesanan berhasil tercatat di sistem Buka Buku.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Pembayaran Lunas',
          time: 'Terverifikasi',
          description: 'Terverifikasi otomatis via QRIS.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Siap Diambil di Toko',
          time: 'Sekarang',
          description: 'Buku telah disiapkan dan dapat diambil di kasir.',
          isActive: true,
        ),
        const OrderTimelineStepModel(
          title: 'Selesai',
          time: '',
          description: 'Menunggu pengambilan buku oleh pembaca.',
        ),
      ];
    } else if (status == OrderStatus.shipping) {
      timeline = [
        OrderTimelineStepModel(
          title: 'Pesanan Dibuat',
          time: dateTimeDisplay,
          description: 'Pesanan berhasil tercatat di sistem Buka Buku.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Pembayaran Lunas',
          time: 'Terverifikasi',
          description: 'Terverifikasi otomatis.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Sedang Dikirim',
          time: 'Dalam Perjalanan',
          description: 'Buku sedang dibawa oleh kurir menuju alamat Anda.',
          isActive: true,
        ),
        const OrderTimelineStepModel(
          title: 'Pesanan Diterima',
          time: '',
          description: 'Menunggu konfirmasi penerimaan paket.',
        ),
      ];
    } else {
      timeline = [
        OrderTimelineStepModel(
          title: 'Pesanan Dibuat',
          time: dateTimeDisplay,
          description: 'Pesanan berhasil tercatat di sistem Buka Buku.',
          isDone: true,
        ),
        const OrderTimelineStepModel(
          title: 'Sedang Diproses',
          time: 'Proses',
          description: 'Kurator buku sedang menyiapkan pesanan Anda.',
          isActive: true,
        ),
        OrderTimelineStepModel(
          title: isDelivery ? 'Pengiriman' : 'Siap Diambil di Toko',
          time: '',
          description: isDelivery
              ? 'Menunggu kurir mengambil paket.'
              : 'Menunggu buku siap di kasir toko.',
        ),
      ];
    }

    return OrderModel(
      id: '#${orderMap['id']}',
      dateTimeStr: dateTimeDisplay,
      orderDateExact: orderDateExact,
      status: status,
      isPaid: orderMap['is_paid'] as bool? ?? false,
      deliveryType: isDelivery ? DeliveryType.delivery : DeliveryType.pickup,
      deliveryBadgeLabel: isDelivery ? 'Kurir Antar' : 'Ambil di Toko',
      pickupLocation: orderMap['pickup_point'] as String? ??
          orderMap['pickup_location'] as String? ??
          'Meja Kasir 1 • Gerai Utama Buka Buku',
      branchName: orderMap['pickup_location'] as String? ??
          orderMap['pickup_point'] as String? ??
          'Gerai Utama Buka Buku',
      branchAddress: 'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat 10330',
      branchSchedule: 'Buka Hari Ini: 08.00 – 21.00 WIB',
      completionNote: status == OrderStatus.completed
          ? (orderMap['completion_note'] as String? ??
              'Buku telah diterima di Gerai Utama Buka Buku')
          : null,
      completionDate: completionDate,
      summaryTitle: summaryTitle,
      summarySubtitle: summarySubtitle,
      summaryItemCountLabel: summaryItemCountLabel,
      summaryCoverUrl: firstItem?.coverUrl ?? '',
      items: items,
      subtotal: itemsSubtotalStr,
      subtotalValue: itemsSubtotalValue,
      shippingCost: isDelivery ? 'Rp12.000' : 'Gratis',
      serviceFee: 'Rp1.000',
      serviceFeeValue: 1000,
      totalAmount: totalStr,
      totalAmountValue: totalPrice,
      paymentMethod: orderMap['payment_method'] as String? ?? 'QRIS',
      customerName: orderMap['customer_name'] as String? ?? 'Pembaca',
      qrCode: orderMap['qr_code'] as String? ??
          orderMap['pickup_code'] as String? ??
          orderMap['id'] as String? ??
          'PKP-ONLINE',
      qrCodeDetail: orderMap['id'] ?? '',
      validUntil: 'Selesai',
      timeline: timeline,
    );
  }

  // ─── READ: Ambil Pesanan Customer (untuk Pesanan Saya) ───────────────────────
  static Future<List<OrderModel>> fetchCustomerOrders({String? userId}) async {
    try {
      String? effectiveUid = userId ?? _client.auth.currentUser?.id;
      if (effectiveUid == null) {
        try {
          final defaultProfile = await _client
              .from('profiles')
              .select('id')
              .eq('role', 'user')
              .limit(1)
              .maybeSingle();
          if (defaultProfile != null) {
            effectiveUid = defaultProfile['id'] as String?;
          }
        } catch (_) {}
      }

      var query = _client.from('orders').select('*, order_items(*)');
      if (effectiveUid != null) {
        query = query.eq('user_id', effectiveUid);
      }
      final response = await query.order('created_at', ascending: false);
      final list = response as List<dynamic>;
      if (list.isEmpty) return [];

      return list
          .map((row) => mapRowToOrderModel(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching customer orders: $e');
      return [];
    }
  }

  // ─── READ: Ambil Detail Pesanan Tunggal untuk Customer (OrderModel) ──────────
  static Future<OrderModel?> fetchOrderByIdForUser(String rawOrderId) async {
    try {
      final cleanId = rawOrderId.replaceAll('#', '').trim();
      if (cleanId.isEmpty) return null;

      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', cleanId)
          .maybeSingle();

      if (response == null) return null;
      return mapRowToOrderModel(response);
    } catch (e) {
      debugPrint('Error fetching user order by ID: $e');
      return null;
    }
  }

  // ─── RE-ADD: Masukkan Ulang Buku-Buku Pesanan ke Keranjang ─────────────────
  static Future<int> reAddItemsToCart(List<OrderItemModel> items) async {
    int count = 0;
    for (final item in items) {
      if (item.bookId != null && item.bookId!.isNotEmpty) {
        try {
          await CartService.addToCart(item.bookId!, quantity: item.quantity);
          count++;
        } catch (e) {
          debugPrint('Error adding book ${item.bookId} to cart: $e');
        }
      }
    }
    return count;
  }

  // ─── CREATE: Buat Pesanan Baru dari Checkout ────────────────────────────────
  static Future<AdminOrderDetail> createOrder({
    String? customOrderId,
    String? userId,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String deliveryType,
    required String paymentMethod,
    String? paymentChannel,
    required bool isPaid,
    AdminOrderStatus status = AdminOrderStatus.baru,
    required int totalPrice,
    int shippingFee = 0,
    int serviceFee = 1000,
    String? specialNote,
    String? pickupCode,
    String? qrCode,
    String? pickupPoint,
    String? accountAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    // 1. Generate Order ID jika belum ada (ORD-yyMMdd-XXXX atau sequential)
    String finalOrderId = customOrderId ?? '';
    if (finalOrderId.isEmpty) {
      final now = DateTime.now();
      final dateCode =
          '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final randomSuffix = (now.millisecondsSinceEpoch % 10000)
          .toString()
          .padLeft(4, '0');
      finalOrderId = 'ORD$dateCode$randomSuffix';
    }

    // 2. Fallback user_id jika null
    String? effectiveUserId = userId ?? _client.auth.currentUser?.id;
    if (effectiveUserId == null) {
      // Ambil user default dari tabel profiles jika ada
      try {
        final defaultProfile = await _client
            .from('profiles')
            .select('id')
            .eq('role', 'user')
            .limit(1)
            .maybeSingle();
        if (defaultProfile != null) {
          effectiveUserId = defaultProfile['id'] as String?;
        }
      } catch (_) {}
    }

    // 3. Tentukan QR Code: Hanya tersedia untuk Ambil di Toko
    final isPickup = deliveryType.toLowerCase().contains('ambil');
    final effectiveQrCode = isPickup ? (qrCode ?? finalOrderId) : null;

    // 4. Insert ke tabel orders
    final orderMap = {
      'id': finalOrderId,
      'user_id': effectiveUserId,
      'customer_name': customerName.trim(),
      'customer_phone': customerPhone.trim(),
      'customer_address': customerAddress.trim(),
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
      'payment_channel': paymentChannel ?? paymentMethod,
      'is_paid': isPaid,
      'status': AdminOrderDetail.statusToString(status),
      'total_price': totalPrice,
      'shipping_fee': shippingFee,
      'service_fee': serviceFee,
      'special_note': specialNote ?? '',
      'pickup_code': pickupCode,
      'qr_code': effectiveQrCode,
      'pickup_point': pickupPoint,
      'account_address': accountAddress ?? customerAddress,
      'is_verified_user': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client.from('orders').insert(orderMap);

    // 4. Insert items ke order_items
    if (items.isNotEmpty) {
      final itemsToInsert = items.map((item) {
        return {
          'order_id': finalOrderId,
          'book_id': item['book_id'] as String?,
          'title': item['title'] as String? ?? 'Buku',
          'author': item['author'] as String? ?? 'Penulis',
          'quantity': (item['quantity'] as num?)?.toInt() ?? 1,
          'price': (item['price'] as num?)?.toInt() ?? 0,
          'rack_location': item['rack_location'] as String?,
          'image_url': item['image_url'] as String?,
          'created_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _client.from('order_items').insert(itemsToInsert);
    }

    // 5. Kembalikan data lengkap pesanan yang baru dibuat
    final created = await fetchOrderById(finalOrderId);
    return created ??
        AdminOrderDetail.fromMap(
          orderMap,
          items,
        );
  }

  // ─── UPDATE: Ubah Status Pesanan ───────────────────────────────────────────
  static Future<void> updateOrderStatus(
    String orderId,
    AdminOrderStatus status, {
    bool setPickupConfirmed = false,
  }) async {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final updateData = <String, dynamic>{
        'status': AdminOrderDetail.statusToString(status),
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (setPickupConfirmed) {
        updateData['pickup_confirmed_at'] = DateTime.now().toIso8601String();
      }
      await _client.from('orders').update(updateData).eq('id', cleanId);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      try {
        Supabase.instance;
        rethrow;
      } catch (_) {
        return;
      }
    }
  }

  // ─── UPDATE: Ubah Status Pembayaran ────────────────────────────────────────
  static Future<void> updateOrderPaymentStatus(
    String orderId,
    bool isPaid, {
    String? paymentMethod,
    AdminOrderStatus? newStatus,
    bool setPickupConfirmed = false,
  }) async {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final updateData = <String, dynamic>{
        'is_paid': isPaid,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (paymentMethod != null) {
        updateData['payment_method'] = paymentMethod;
      }
      if (newStatus != null) {
        updateData['status'] = AdminOrderDetail.statusToString(newStatus);
      } else if (isPaid) {
        updateData['status'] = 'diproses';
      }
      if (setPickupConfirmed) {
        updateData['pickup_confirmed_at'] = DateTime.now().toIso8601String();
      }

      await _client.from('orders').update(updateData).eq('id', cleanId);
    } catch (e) {
      debugPrint('Error updating order payment status: $e');
      try {
        Supabase.instance;
        rethrow;
      } catch (_) {
        return;
      }
    }
  }

  // ─── REALTIME: Langganan Perubahan Pesanan Global ───────────────────────────
  static RealtimeChannel? subscribeToOrders({
    required void Function() onData,
  }) {
    try {
      final channel = _client.channel('public:orders_realtime');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              onData();
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Error subscribing to orders: $e');
      return null;
    }
  }

  // ─── REALTIME: Langganan Perubahan Status Pesanan Spesifik (Untuk User) ────
  static RealtimeChannel? subscribeToOrderChanges({
    required String orderId,
    required void Function(String newStatus) onStatusChanged,
  }) {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final channelName = 'order_status_${cleanId}_${DateTime.now().millisecondsSinceEpoch}';
      final channel = _client.channel(channelName);
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'orders',
            callback: (payload) {
              final record = payload.newRecord;
              if (record['id'] == cleanId) {
                final newStatus = record['status'] as String?;
                if (newStatus != null) {
                  onStatusChanged(newStatus);
                }
              }
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Error subscribing to order changes: $e');
      return null;
    }
  }
}
