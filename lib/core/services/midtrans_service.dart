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
}

