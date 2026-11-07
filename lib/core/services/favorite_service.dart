import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/favorite/models/favorite_item.dart';

class FavoriteService {
  static SupabaseClient get _client => Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;

  /// Fetch all favorite books for the logged-in user with joined book details
  static Future<List<FavoriteItem>> fetchFavorites() async {
    final userId = currentUserId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('favorite_items')
          .select('id, user_id, book_id, created_at, books(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = response as List<dynamic>;
      return list
          .map((e) => FavoriteItem.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check whether a book is favorited by the current user
  static Future<bool> isFavorite(String bookId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    try {
      final row = await _client
          .from('favorite_items')
          .select('id')
          .eq('user_id', userId)
          .eq('book_id', bookId)
          .maybeSingle();

      return row != null;
    } catch (_) {
      return false;
    }
  }

  /// Toggle favorite status. Returns `true` if added, `false` if removed.
  static Future<bool> toggleFavorite(String bookId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User belum masuk akun');
    }

    final existing = await _client
        .from('favorite_items')
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('favorite_items')
          .delete()
          .eq('id', existing['id']);
      return false;
    } else {
      await _client.from('favorite_items').insert({
        'user_id': userId,
        'book_id': bookId,
      });
      return true;
    }
  }

  /// Remove favorite by record ID
  static Future<void> removeFavorite(String favoriteItemId) async {
    await _client.from('favorite_items').delete().eq('id', favoriteItemId);
  }

  /// Remove favorite by book ID for current user
  static Future<void> removeFavoriteByBookId(String bookId) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client
        .from('favorite_items')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }

  /// Get total favorite count for the current user
  static Future<int> getFavoriteCount() async {
    final userId = currentUserId;
    if (userId == null) return 0;

    final response = await _client
        .from('favorite_items')
        .select('id')
        .eq('user_id', userId);

    return (response as List<dynamic>).length;
  }
}

