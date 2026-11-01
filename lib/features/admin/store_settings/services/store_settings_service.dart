import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/store_settings_model.dart';

/// Service for managing physical bookstore settings in Supabase.
class StoreSettingsService {
  static StoreSettingsModel? _cachedSettings;

  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Current cached settings or initial data if not yet loaded
  static StoreSettingsModel get currentSettings =>
      _cachedSettings ?? StoreSettingsModel.initialData;

  /// Fetches the latest store settings from Supabase.
  static Future<StoreSettingsModel> fetchStoreSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSettings != null) {
      return _cachedSettings!;
    }

    final client = _client;
    if (client == null) {
      _cachedSettings = StoreSettingsModel.initialData;
      return _cachedSettings!;
    }

    try {
      final response = await client
          .from('store_settings')
          .select()
          .eq('id', 'main_store')
          .maybeSingle();

      if (response != null) {
        _cachedSettings = StoreSettingsModel.fromSupabase(response);
      } else {
        _cachedSettings = StoreSettingsModel.initialData;
      }
      return _cachedSettings!;
    } catch (e) {
      debugPrint('Error fetching store settings from Supabase: $e');
      _cachedSettings = StoreSettingsModel.initialData;
      return _cachedSettings!;
    }
  }

  /// Updates store settings in Supabase.
  static Future<bool> updateStoreSettings(StoreSettingsModel settings) async {
    final client = _client;
    _cachedSettings = settings;

    if (client == null) return true;

    try {
      final payload = settings.toSupabaseMap();
      payload['id'] = 'main_store';

      await client.from('store_settings').upsert(payload);
      return true;
    } catch (e) {
      debugPrint('Error updating store settings in Supabase: $e');
      return false;
    }
  }

  /// Resets store settings to initial default data in Supabase.
  static Future<bool> resetToDefault() async {
    return await updateStoreSettings(StoreSettingsModel.initialData);
  }
}
