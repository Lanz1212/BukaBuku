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

  /// Uploads avatar image to Supabase Storage bucket 'avatars'
  /// and updates the 'avatar_url' column in the user's profile.
  /// Returns the public URL with cache-busting timestamp on success, or null on error.
  static Future<String?> uploadAvatar({
    required Uint8List bytes,
    String fileExtension = 'jpg',
  }) async {
    final client = _client;
    if (client == null) return null;

    try {
      final user = client.auth.currentUser;
      if (user == null) {
        debugPrint('Cannot upload avatar: No logged-in user.');
        return null;
      }

      final userId = user.id;
      final cleanExt = fileExtension.replaceAll('.', '').toLowerCase();
      final mimeType = cleanExt == 'png'
          ? 'image/png'
          : (cleanExt == 'webp' ? 'image/webp' : 'image/jpeg');
      final fileName = 'avatar.$cleanExt';
      final storagePath = '$userId/$fileName';

      // Upload binary to Supabase Storage (upsert: true to overwrite previous avatar)
      await client.storage.from('avatars').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = client.storage.from('avatars').getPublicUrl(storagePath);
      final timestampedUrl =
          '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Update avatar_url in the profiles table
      await client.from('profiles').update({
        'avatar_url': timestampedUrl,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      return timestampedUrl;
    } catch (e) {
      debugPrint('Error uploading avatar to Supabase: $e');
      return null;
    }
  }

  /// Removes avatar from Supabase Storage and clears avatar_url in profiles table.
  static Future<bool> removeAvatar() async {
    final client = _client;
    if (client == null) return false;

    try {
      final user = client.auth.currentUser;
      if (user == null) return false;

      final userId = user.id;
      try {
        final files = await client.storage.from('avatars').list(path: userId);
        if (files.isNotEmpty) {
          final filePaths = files.map((f) => '$userId/${f.name}').toList();
          await client.storage.from('avatars').remove(filePaths);
        }
      } catch (storageError) {
        debugPrint('Warning removing avatar files from storage: $storageError');
      }

      await client.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error removing avatar: $e');
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
          .select('addresses, full_name, phone')
          .eq('id', user.id)
          .maybeSingle();

      final raw = data?['addresses'] as String?;
      if (raw == null || raw.trim().isEmpty) {
        return [];
      }

      final trimmed = raw.trim();

      // If it's a valid JSON array or object
      if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return decoded
                .map(
                  (item) => ShippingAddress.fromMap(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList();
          } else if (decoded is Map) {
            return [
              ShippingAddress.fromMap(Map<String, dynamic>.from(decoded)),
            ];
          }
        } catch (e) {
          debugPrint('Warning parsing addresses JSON: $e');
        }
      }

      // Graceful fallback for non-JSON string (e.g. plain text addresses)
      final name = (data?['full_name'] as String?)?.trim();
      final phone = (data?['phone'] as String?)?.trim();
      return [
        ShippingAddress(
          id: 'addr_default',
          recipientName: (name != null && name.isNotEmpty) ? name : 'Penerima',
          phoneNumber: phone ?? '',
          label: 'Rumah',
          fullAddress: trimmed,
          isPrimary: true,
          isGeotagVerified: false,
        ),
      ];
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
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error saving user addresses: $e');
      return false;
    }
  }
}
