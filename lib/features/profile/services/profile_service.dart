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
  /// including real-time order count from public.orders.
  static Future<UserProfile> fetchCurrentUserProfile() async {
    final client = _client;
    if (client == null) {
      return UserProfile.defaultProfile;
    }

    try {
      final user = client.auth.currentUser;
      String? userId = user?.id;

      // If no authenticated session (e.g. testing), check if default customer exists
      Map<String, dynamic>? data;
      if (userId != null) {
        data = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
      }

      if (data == null) {
        data = await client
            .from('profiles')
            .select()
            .eq('email', 'testpembeli@tokobukubudi.id')
            .maybeSingle();
        if (data != null) {
          userId = data['id']?.toString();
        }
      }

      if (data == null) {
        return UserProfile.defaultProfile;
      }

      // Query real count of orders placed by this user
      int orderCount = 0;
      if (userId != null) {
        try {
          final orders = await client
              .from('orders')
              .select('id')
              .eq('user_id', userId);
          orderCount = (orders as List).length;
        } catch (_) {}
      }

      return UserProfile.fromSupabase(data, orderCount: orderCount);
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
      final userId = user?.id ?? (profile.id.isNotEmpty && profile.id != 'user_001' ? profile.id : null);

      if (userId != null) {
        await client
            .from('profiles')
            .update(profile.toSupabaseMap())
            .eq('id', userId);
      } else {
        await client
            .from('profiles')
            .update(profile.toSupabaseMap())
            .eq('email', profile.email);
      }
      return true;
    } catch (e) {
      debugPrint('Error updating profile in Supabase: $e');
      return false;
    }
  }

  /// Fetches stored shipping addresses for the user.
  static Future<List<ShippingAddress>> fetchUserAddresses() async {
    final client = _client;
    if (client == null) return List.from(ShippingAddress.defaultAddresses);

    try {
      final user = client.auth.currentUser;
      Map<String, dynamic>? data;

      if (user?.id != null) {
        data = await client
            .from('profiles')
            .select('addresses')
            .eq('id', user!.id)
            .maybeSingle();
      }

      if (data == null || data['addresses'] == null) {
        data = await client
            .from('profiles')
            .select('addresses')
            .eq('email', 'testpembeli@tokobukubudi.id')
            .maybeSingle();
      }

      final raw = data?['addresses'] as String?;
      if (raw == null || raw.trim().isEmpty) {
        return List.from(ShippingAddress.defaultAddresses);
      }

      // If stored as JSON list
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded
              .map((item) => ShippingAddress.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      } catch (_) {
        // Plain string fallback
        return [
          ShippingAddress(
            id: 'addr_saved_01',
            recipientName: 'Budi Santoso',
            phoneNumber: '+62 812-3456-7890',
            label: 'Alamat Pengiriman',
            fullAddress: raw,
            isPrimary: true,
            isGeotagVerified: true,
          ),
        ];
      }

      return List.from(ShippingAddress.defaultAddresses);
    } catch (e) {
      debugPrint('Error fetching user addresses: $e');
      return List.from(ShippingAddress.defaultAddresses);
    }
  }

  /// Persists shipping addresses list to Supabase.
  static Future<bool> saveUserAddresses(List<ShippingAddress> addresses) async {
    final client = _client;
    if (client == null) return true;

    try {
      final user = client.auth.currentUser;
      final jsonStr = jsonEncode(addresses.map((a) => a.toMap()).toList());

      if (user?.id != null) {
        await client
            .from('profiles')
            .update({'addresses': jsonStr, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', user!.id);
      } else {
        await client
            .from('profiles')
            .update({'addresses': jsonStr, 'updated_at': DateTime.now().toIso8601String()})
            .eq('email', 'testpembeli@tokobukubudi.id');
      }
      return true;
    } catch (e) {
      debugPrint('Error saving user addresses: $e');
      return false;
    }
  }
}
