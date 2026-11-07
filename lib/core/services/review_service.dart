import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/review/models/book_review.dart';

class ReviewService {
  static SupabaseClient get _client => Supabase.instance.client;

  static SupabaseClient? get _safeClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Ambil ID user saat ini (dengan fallback ke profil user default jika belum login)
  static Future<String?> getEffectiveUserId() async {
    final client = _safeClient;
    if (client == null) return null;

    final authUid = client.auth.currentUser?.id;
    if (authUid != null) return authUid;

    try {
      final defaultProfile = await client
          .from('profiles')
          .select('id')
          .eq('role', 'user')
          .limit(1)
          .maybeSingle();
      if (defaultProfile != null) {
        return defaultProfile['id'] as String?;
      }
    } catch (e) {
      debugPrint('Error getting default profile ID: $e');
    }
    return null;
  }

  /// Ambil info profil user saat ini (nama & avatar)
  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final client = _safeClient;
    if (client == null) {
      return {'id': '', 'full_name': 'Pembaca Toko Buku', 'avatar_url': null};
    }

    final uid = await getEffectiveUserId();
    if (uid == null) {
      return {'id': '', 'full_name': 'Pembaca Toko Buku', 'avatar_url': null};
    }

    try {
      final row = await client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .eq('id', uid)
          .maybeSingle();
      if (row != null) {
        return {
          'id': uid,
          'full_name': (row['full_name'] as String?)?.trim() ?? 'Pembaca Toko Buku',
          'avatar_url': row['avatar_url'] as String?,
        };
      }
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
    }

    return {'id': uid, 'full_name': 'Pembaca Toko Buku', 'avatar_url': null};
  }

  /// Ambil semua ulasan untuk suatu buku (dari database nyata)
  static Future<List<BookReview>> fetchBookReviews(String bookId) async {
    final client = _safeClient;
    if (client == null) return [];

    try {
      final response = await client
          .from('book_reviews')
          .select()
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((e) => BookReview.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching book reviews: $e');
      return [];
    }
  }

  /// Cek apakah user sudah memberikan ulasan untuk buku ini
  static Future<BookReview?> fetchUserReviewForBook(String bookId, {String? userId}) async {
    final client = _safeClient;
    if (client == null) return null;

    try {
      final effectiveUid = userId ?? await getEffectiveUserId();
      if (effectiveUid == null) return null;

      final response = await client
          .from('book_reviews')
          .select()
          .eq('book_id', bookId)
          .eq('user_id', effectiveUid)
          .maybeSingle();

      if (response == null) return null;
      return BookReview.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching user review: $e');
      return null;
    }
  }

  /// Cek apakah user pernah membeli buku ini pada pesanan yang statusnya 'selesai'
  /// Mengembalikan Map berisi `hasPurchased` (bool) dan `orderId` (String?)
  static Future<Map<String, dynamic>> checkPurchaseEligibility(
    String bookId, {
    String? userId,
  }) async {
    final client = _safeClient;
    if (client == null) {
      return {'hasPurchased': false, 'orderId': null};
    }

    try {
      final effectiveUid = userId ?? await getEffectiveUserId();
      if (effectiveUid == null) {
        return {'hasPurchased': false, 'orderId': null};
      }

      // Ambil pesanan yang berstatus 'selesai' dari user ini
      final orders = await client
          .from('orders')
          .select('id, status, order_items(book_id)')
          .eq('user_id', effectiveUid)
          .eq('status', 'selesai');

      for (final order in orders as List<dynamic>) {
        final orderMap = order as Map<String, dynamic>;
        final orderId = orderMap['id'] as String;
        final items = orderMap['order_items'] as List<dynamic>? ?? [];

        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          if (itemMap['book_id'] == bookId) {
            return {'hasPurchased': true, 'orderId': orderId};
          }
        }
      }

      return {'hasPurchased': false, 'orderId': null};
    } catch (e) {
      debugPrint('Error checking purchase eligibility: $e');
      return {'hasPurchased': false, 'orderId': null};
    }
  }

  /// Simpan ulasan baru atau update jika sudah ada (Upsert)
  static Future<void> submitOrUpdateReview({
    required String bookId,
    required String orderId,
    required int rating,
    required String comment,
    int? existingReviewId,
  }) async {
    final profile = await getCurrentUserProfile();
    final effectiveUid = profile['id'] as String;
    if (effectiveUid.isEmpty) {
      throw Exception('Sesi pengguna tidak valid. Silakan login kembali.');
    }

    final data = {
      'book_id': bookId,
      'user_id': effectiveUid,
      'order_id': orderId,
      'user_name': profile['full_name'],
      'user_avatar': profile['avatar_url'],
      'rating': rating,
      'comment': comment.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existingReviewId != null && existingReviewId > 0) {
      await _client
          .from('book_reviews')
          .update(data)
          .eq('id', existingReviewId);
    } else {
      // Periksa apakah user sudah pernah ulas sebelumnya untuk mencegah duplicate key
      final existing = await fetchUserReviewForBook(bookId, userId: effectiveUid);
      if (existing != null) {
        await _client
            .from('book_reviews')
            .update(data)
            .eq('id', existing.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await _client.from('book_reviews').insert(data);
      }
    }
  }

  /// Hapus ulasan
  static Future<void> deleteReview(int reviewId) async {
    await _client.from('book_reviews').delete().eq('id', reviewId);
  }
}

