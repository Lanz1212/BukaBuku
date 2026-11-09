import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/admin/profile/models/cashier_activity_log.dart';

/// Service untuk membaca dan mencatat log audit / aktivitas staf kasir & admin ke Supabase
class CashierLogService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // Cache nama admin yang sedang login untuk meminimalkan query berulang
  static String? _cachedAdminName;

  /// Hapus cache nama admin (misalnya saat logout atau edit profil)
  static void clearCachedAdminName() {
    _cachedAdminName = null;
  }

  /// Dapatkan nama admin yang sedang login dari tabel profiles (full_name)
  static Future<String> getCurrentAdminName() async {
    if (_cachedAdminName != null && _cachedAdminName!.isNotEmpty) {
      return _cachedAdminName!;
    }

    final client = _client;
    if (client == null) return 'Admin Toko';

    final user = client.auth.currentUser;
    if (user == null) return 'Admin Toko';

    try {
      final profile = await client
          .from('profiles')
          .select('full_name, email')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        final fullName = (profile['full_name'] as String?)?.trim();
        if (fullName != null && fullName.isNotEmpty) {
          _cachedAdminName = fullName;
          return fullName;
        }
      }

      // Fallback ke userMetadata jika profil belum terisi
      final meta = user.userMetadata ?? {};
      final metaName = (meta['full_name'] as String?)?.trim();
      if (metaName != null && metaName.isNotEmpty) {
        _cachedAdminName = metaName;
        return metaName;
      }

      // Fallback ke awalan email
      final emailPrefix = user.email?.split('@').first;
      if (emailPrefix != null && emailPrefix.isNotEmpty) {
        _cachedAdminName = emailPrefix;
        return emailPrefix;
      }
    } catch (e) {
      debugPrint('Error getting admin name from profiles: $e');
    }

    return 'Admin Toko';
  }

  /// Ambil daftar log aktivitas kasir dengan opsi filter tag & pencarian.
  /// Dimulai dari kosong bersih (tidak menggunakan data dummy).
  static Future<List<CashierActivityLog>> fetchLogs({
    String? tagFilter,
    String? searchQuery,
    int limit = 100,
  }) async {
    final client = _client;
    if (client == null) {
      return [];
    }

    try {
      var query = client.from('cashier_activity_logs').select('*');

      if (tagFilter != null && tagFilter.isNotEmpty && tagFilter != 'Semua') {
        query = query.eq('tag', tagFilter);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim();
        query = query.or('action.ilike.%$q%,details.ilike.%$q%,cashier_name.ilike.%$q%,order_id.ilike.%$q%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      return list
          .map((row) => CashierActivityLog.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching cashier logs from Supabase: $e');
      return [];
    }
  }

  /// Catat aktivitas baru ke Supabase.
  /// Jika cashierName tidak diisi, otomatis mengambil nama admin yang login dari profil.
  static Future<bool> recordLog({
    required String action,
    String? cashierName,
    String? details,
    String? orderId,
    String tag = 'Kasir',
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      final effectiveName = (cashierName != null && cashierName.trim().isNotEmpty)
          ? cashierName.trim()
          : await getCurrentAdminName();

      await client.from('cashier_activity_logs').insert({
        'cashier_name': effectiveName,
        'action': action,
        'details': details,
        'order_id': orderId,
        'tag': tag,
      });
      return true;
    } catch (e) {
      debugPrint('Error recording cashier log to Supabase: $e');
      return false;
    }
  }
}
