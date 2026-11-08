import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/midtrans_constants.dart';
import '../constants/supabase_constants.dart';

class MidtransSnapResponse {
  final String token;
  final String redirectUrl;

  const MidtransSnapResponse({
    required this.token,
    required this.redirectUrl,
  });

  factory MidtransSnapResponse.fromJson(Map<String, dynamic> json) {
    return MidtransSnapResponse(
      token: json['token'] as String? ?? '',
      redirectUrl: json['redirect_url'] as String? ?? '',
    );
  }
}

class MidtransTransactionStatus {
  final String orderId;
  final String transactionStatus; // settlement, capture, pending, deny, cancel, expire, not_found, unknown
  final String? fraudStatus;
  final String? paymentType;
  final int? grossAmount;
  final String? transactionTime;
  final String? statusCode;
  final String? statusMessage;

  const MidtransTransactionStatus({
    required this.orderId,
    required this.transactionStatus,
    this.fraudStatus,
    this.paymentType,
    this.grossAmount,
    this.transactionTime,
    this.statusCode,
    this.statusMessage,
  });

  /// Transaksi benar-benar sudah lunas di Midtrans
  bool get isPaid =>
      transactionStatus == 'settlement' ||
      transactionStatus == 'success' ||
      (transactionStatus == 'capture' &&
          (fraudStatus == null || fraudStatus == 'accept')) ||
      (statusCode == '200' &&
          transactionStatus != 'pending' &&
          transactionStatus != 'deny' &&
          transactionStatus != 'cancel' &&
          transactionStatus != 'expire' &&
          transactionStatus != 'not_found' &&
          transactionStatus != 'unknown');

  /// Transaksi masih menunggu pembayaran
  bool get isPending => transactionStatus == 'pending';

  /// Transaksi belum pernah dibuat / tidak ditemukan di Midtrans
  bool get isNotFound =>
      transactionStatus == 'not_found' || statusCode == '404';

  /// Transaksi ditolak, dibatalkan, atau kadaluarsa
  bool get isFailed =>
      transactionStatus == 'deny' ||
      transactionStatus == 'cancel' ||
      transactionStatus == 'expire' ||
      transactionStatus == 'failure';

  factory MidtransTransactionStatus.fromJson(
    Map<String, dynamic> json,
    String fallbackOrderId,
  ) {
    final status = (json['transaction_status'] as String? ?? '').toLowerCase();
    final sCode = json['status_code']?.toString();
    final sMsg = json['status_message'] as String?;

    return MidtransTransactionStatus(
      orderId: (json['order_id'] as String?) ?? fallbackOrderId,
      transactionStatus: status.isNotEmpty
          ? status
          : (sCode == '404' ? 'not_found' : 'unknown'),
      fraudStatus: (json['fraud_status'] as String?)?.toLowerCase(),
      paymentType: json['payment_type'] as String?,
      grossAmount: (json['gross_amount'] as num?)?.toInt() ??
          int.tryParse(json['gross_amount']?.toString().split('.').first ?? ''),
      transactionTime: json['transaction_time'] as String?,
      statusCode: sCode,
      statusMessage: sMsg,
    );
  }
}

class MidtransService {
  /// Meminta Snap Token dan Redirect URL dari Midtrans via Supabase Edge Function
  static Future<MidtransSnapResponse> createSnapToken({
    required String orderId,
    required int amount,
    required String customerName,
    String? customerEmail,
    required String customerPhone,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final url = Uri.parse(MidtransConstants.edgeFunctionUrl);

      // Siapkan payload request
      final Map<String, dynamic> requestBody = {
        'orderId': orderId,
        'amount': amount,
        'customerName': customerName,
        'customerEmail': customerEmail ?? 'customer@bukabuku.id',
        'customerPhone': customerPhone,
        'items': items,
      };

      // Jika user mengisi serverKey di MidtransConstants, kirimkan juga sebagai override
      if (MidtransConstants.serverKey.isNotEmpty &&
          MidtransConstants.serverKey != 'YOUR_MIDTRANS_SERVER_KEY') {
        requestBody['serverKeyOverride'] = MidtransConstants.serverKey;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseConstants.supabaseAnonKey}',
        },
        body: jsonEncode(requestBody),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = decoded['token'] as String?;
        final redirectUrl = decoded['redirect_url'] as String? ??
            (token != null ? '${MidtransConstants.snapRedirectionBaseUrl}$token' : '');

        if (token != null && token.isNotEmpty) {
          return MidtransSnapResponse(
            token: token,
            redirectUrl: redirectUrl,
          );
        }
      }

      final errorMessage = decoded['error'] ??
          decoded['message'] ??
          decoded['details'] ??
          'Status: ${response.statusCode} - ${response.body}';
      throw Exception('Gagal membuat transaksi Midtrans: $errorMessage');
    } catch (e) {
      debugPrint('MidtransService Error: $e');
      rethrow;
    }
  }

  /// Memeriksa status transaksi dari server Midtrans via Supabase Edge Function
  static Future<MidtransTransactionStatus> checkTransactionStatus(
    String orderId,
  ) async {
    final cleanOrderId = orderId.replaceAll('#', '').trim();

    try {
      final url = Uri.parse(MidtransConstants.checkStatusFunctionUrl);

      final Map<String, dynamic> requestBody = {
        'orderId': cleanOrderId,
      };

      if (MidtransConstants.serverKey.isNotEmpty &&
          MidtransConstants.serverKey != 'YOUR_MIDTRANS_SERVER_KEY') {
        requestBody['serverKeyOverride'] = MidtransConstants.serverKey;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': SupabaseConstants.supabaseAnonKey,
          'Authorization': 'Bearer ${SupabaseConstants.supabaseAnonKey}',
        },
        body: jsonEncode(requestBody),
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return MidtransTransactionStatus.fromJson(decoded, cleanOrderId);
    } catch (e) {
      debugPrint('MidtransService.checkTransactionStatus via Edge Function Error: $e');

      // Fallback: Langsung panggil API Midtrans jika Edge Function gagal/offline
      if (MidtransConstants.serverKey.isNotEmpty &&
          MidtransConstants.serverKey != 'YOUR_MIDTRANS_SERVER_KEY') {
        try {
          final baseUrl = MidtransConstants.isProduction
              ? 'https://api.midtrans.com/v2'
              : 'https://api.sandbox.midtrans.com/v2';
          final directUrl = Uri.parse('$baseUrl/$cleanOrderId/status');
          final basicAuth = base64Encode(
            utf8.encode('${MidtransConstants.serverKey.trim()}:'),
          );

          final directRes = await http.get(
            directUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Basic $basicAuth',
            },
          );
          final directDecoded = jsonDecode(directRes.body) as Map<String, dynamic>;
          return MidtransTransactionStatus.fromJson(directDecoded, cleanOrderId);
        } catch (directErr) {
          debugPrint('Midtrans direct fallback error: $directErr');
        }
      }

      rethrow;
    }
  }
}
