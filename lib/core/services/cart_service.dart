import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/cart/models/cart_item.dart';

class CartService {
  static SupabaseClient get _client => Supabase.instance.client;
  static String? get currentUserId => _client.auth.currentUser?.id;

  /// Global notifier for total items in user's cart
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  /// Fetch all cart items for the logged-in user with joined book details
  static Future<List<CartItem>> fetchCartItems() async {
    final userId = currentUserId;
    if (userId == null) {
      cartCountNotifier.value = 0;
      return [];
    }

    try {
      final response = await _client
          .from('cart_items')
          .select('id, user_id, book_id, quantity, is_selected, created_at, books(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final list = response as List<dynamic>;
      final items = list
          .map((e) => CartItem.fromSupabase(e as Map<String, dynamic>))
          .toList();
      cartCountNotifier.value = items.length;
      return items;
    } catch (e) {
      // Return empty list on failure or rethrow if needed
      return [];
    }
  }

  /// Add book to cart or increase quantity if it already exists
  static Future<void> addToCart(String bookId, {int quantity = 1}) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User belum masuk akun');
    }

    // Check if item already exists in user's cart
    final existing = await _client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    if (existing != null) {
      final currentQty = (existing['quantity'] as num?)?.toInt() ?? 1;
      final newQty = currentQty + quantity;
      await _client
          .from('cart_items')
          .update({
            'quantity': newQty,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('cart_items').insert({
        'user_id': userId,
        'book_id': bookId,
        'quantity': quantity,
        'is_selected': true,
      });
    }

    await getCartItemCount();
  }

  /// Update item quantity directly
  static Future<void> updateQuantity(String cartItemId, int newQty) async {
    if (newQty < 1) return;
    await _client
        .from('cart_items')
        .update({
          'quantity': newQty,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cartItemId);
  }

  /// Update single item selection status
  static Future<void> updateSelection(String cartItemId, bool isSelected) async {
    await _client
        .from('cart_items')
        .update({
          'is_selected': isSelected,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', cartItemId);
  }

  /// Toggle all items selection status for the current user
  static Future<void> updateAllSelection(bool isSelected) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _client
        .from('cart_items')
        .update({
          'is_selected': isSelected,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  /// Remove single cart item by cart record ID
  static Future<void> removeCartItem(String cartItemId) async {
    await _client.from('cart_items').delete().eq('id', cartItemId);
    await getCartItemCount();
  }

  /// Remove multiple cart items by their record IDs
  static Future<void> removeCartItems(List<String> cartItemIds) async {
    if (cartItemIds.isEmpty) return;
    await _client.from('cart_items').delete().filter('id', 'in', cartItemIds);
    await getCartItemCount();
  }

  /// Remove cart item by bookId for current user
  static Future<void> removeCartItemByBookId(String bookId) async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
    await getCartItemCount();
  }

  /// Clear all cart items for current user
  static Future<void> clearCart() async {
    final userId = currentUserId;
    if (userId == null) return;
    await _client.from('cart_items').delete().eq('user_id', userId);
    cartCountNotifier.value = 0;
  }

  /// Check whether a book is already in current user's cart
  static Future<bool> isBookInCart(String bookId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final row = await _client
        .from('cart_items')
        .select('id')
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    return row != null;
  }

  /// Get total item count in user's cart
  static Future<int> getCartItemCount() async {
    final userId = currentUserId;
    if (userId == null) {
      cartCountNotifier.value = 0;
      return 0;
    }

    try {
      final response = await _client
          .from('cart_items')
          .select('id')
          .eq('user_id', userId);

      final count = (response as List<dynamic>).length;
      cartCountNotifier.value = count;
      return count;
    } catch (_) {
      return cartCountNotifier.value;
    }
  }
}

