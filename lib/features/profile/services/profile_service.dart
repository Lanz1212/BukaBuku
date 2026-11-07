import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/shipping_address.dart';

/// Service for managing user profile and shipping addresses in Supabase.
class ProfileService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Fetches the profile of the current logged-in user,
  /// including real-time order count and favorite count from database.
  static Future<UserProfile> fetchCurrentUserProfile() async {
    final client = _client;
    if (client == null) {
      return UserProfile.defaultProfile;
    }

    try {
      final user = client.auth.currentUser;
      if (user == null) {
        return UserProfile.defaultProfile;
      }
      final userId = user.id;

      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return UserProfile(
          id: userId,
          name: user.email?.split('@').first ?? 'Pengguna',
          email: user.email ?? '',
          phone: '',
        );
      }

      // Query real count of orders placed by this user
      int orderCount = 0;
      try {
        final orders = await client
            .from('orders')
            .select('id')
            .eq('user_id', userId);
        orderCount = (orders as List).length;
      } catch (e) {
        debugPrint('Error counting orders: $e');
      }

      // Query real count of favorite books saved by this user
      int favoriteCount = 0;
      try {
        final favorites = await client
            .from('favorite_items')
            .select('id')
            .eq('user_id', userId);
        favoriteCount = (favorites as List).length;
      } catch (e) {
        debugPrint('Error counting favorites: $e');
      }

      return UserProfile.fromSupabase(
        data,
        orderCount: orderCount,
        favoriteCount: favoriteCount,
        activeVouchers: 0,
      );
    } catch (e) {
      debugPrint('Error fetching user profile from Supabase: $e');
      return UserProfile.defaultProfile;
    }
  }

  /// Updates profile in Supabase profiles table.
  static Future<bool> updateProfile(UserProfile profile) async {
    final client = _client;
    if (client == null) return true;

    try {
      final user = client.auth.currentUser;
      final userId = user?.id ?? (profile.id.isNotEmpty ? profile.id : null);

      if (userId == null) return false;

      await client
          .from('profiles')
          .update(profile.toSupabaseMap())
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error updating profile in Supabase: $e');
      return false;
    }
  }

  /// Fetches stored shipping addresses for the logged-in user.
  static Future<List<ShippingAddress>> fetchUserAddresses() async {
    final client = _client;
    if (client == null) return [];

    try {
      final user = client.auth.currentUser;
      if (user == null) return [];

      final data = await client
          .from('profiles')
          .select('addresses')
          .eq('id', user.id)
          .maybeSingle();

      final raw = data?['addresses'] as String?;
      if (raw == null || raw.trim().isEmpty) {
        return [];
      }

      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((item) => ShippingAddress.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      } catch (e) {
        debugPrint('Error decoding addresses JSON: $e');
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching user addresses: $e');
      return [];
    }
  }

  /// Persists shipping addresses list to Supabase for the logged-in user.
  static Future<bool> saveUserAddresses(List<ShippingAddress> addresses) async {
    final client = _client;
    if (client == null) return false;

    try {
      final user = client.auth.currentUser;
      if (user == null) return false;

      final jsonStr = jsonEncode(addresses.map((a) => a.toMap()).toList());

      await client
          .from('profiles')
          .update({
            'addresses': jsonStr,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error saving user addresses: $e');
      return false;
    }
  }
}
