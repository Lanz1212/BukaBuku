import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_notification_item.dart';

class AdminNotificationService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Notifier untuk realtime badge counter di AdminAppBar
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// Cache admin user IDs
  static List<String>? _cachedAdminIds;

  /// Ambil semua profile ID yang memiliki role admin
  static Future<List<String>> _getAdminUserIds() async {
    if (_cachedAdminIds != null && _cachedAdminIds!.isNotEmpty) {
      return _cachedAdminIds!;
    }

    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('role', 'admin');

      final list = (response as List<dynamic>)
          .map((row) => (row['id'] as String?)?.trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      if (list.isNotEmpty) {
        _cachedAdminIds = list;
        return list;
      }
    } catch (e) {
      debugPrint('Error getting admin user IDs: $e');
    }

    return [];
  }

  /// Kirim notifikasi broadcast ke seluruh akun admin
  static Future<bool> broadcastToAdmins({
    required String type,
    required String category,
    required String title,
    required String body,
    String? orderId,
    String? refId,
  }) async {
    try {
      final adminIds = await _getAdminUserIds();
      final nowStr = DateTime.now().toIso8601String();

      // Bersihkan format ID jika ada tanda pagar
      final cleanOrderId = orderId?.replaceAll('#', '').trim();

      if (adminIds.isNotEmpty) {
        // Buat baris notifikasi untuk tiap admin
        final rows = adminIds.map((adminId) {
          return {
            'target_role': 'admin',
            'user_id': adminId,
            'title': title,
            'body': body,
            'category': category,
            'type': type,
            'is_unread': true,
            'order_id': (cleanOrderId != null && cleanOrderId.isNotEmpty) ? cleanOrderId : null,
            'ref_id': refId,
            'created_at': nowStr,
          };
        }).toList();

        await _client.from('notifications').insert(rows);
      } else {
        // Fallback jika belum ada user admin terdaftar
        await _client.from('notifications').insert({
          'target_role': 'admin',
          'user_id': null,
          'title': title,
          'body': body,
          'category': category,
          'type': type,
          'is_unread': true,
          'order_id': (cleanOrderId != null && cleanOrderId.isNotEmpty) ? cleanOrderId : null,
          'ref_id': refId,
          'created_at': nowStr,
        });
      }

      // Update local unread count
      unreadCountNotifier.value += 1;
      debugPrint('Admin notification broadcasted: $type - $title');
      return true;
    } catch (e) {
      debugPrint('Error broadcasting admin notification: $e');
      return false;
    }
  }

  /// Ambil daftar notifikasi admin dari Supabase
  static Future<List<AdminNotificationItem>> fetchAdminNotifications({
    AdminNotifCategory category = AdminNotifCategory.all,
    int limit = 100,
  }) async {
    try {
      var query = _client
          .from('notifications')
          .select()
          .eq('target_role', 'admin');

      if (category != AdminNotifCategory.all) {
        String catStr = 'order';
        if (category == AdminNotifCategory.stock) {
          catStr = 'stock';
        } else if (category == AdminNotifCategory.inventory) {
          catStr = 'inventory';
        }
        query = query.eq('category', catStr);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final list = response as List<dynamic>;
      final items = list
          .map((row) => AdminNotificationItem.fromMap(row as Map<String, dynamic>))
          .toList();

      // Update badge unread count
      final unreadCount = items.where((i) => i.isUnread).length;
      unreadCountNotifier.value = unreadCount;

      return items;
    } catch (e) {
      debugPrint('Error fetching admin notifications: $e');
      return [];
    }
  }

  /// Hitung total notifikasi admin yang belum dibaca
  static Future<int> countUnread() async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('target_role', 'admin')
          .eq('is_unread', true);

      final count = (response as List<dynamic>).length;
      unreadCountNotifier.value = count;
      return count;
    } catch (e) {
      debugPrint('Error counting unread admin notifications: $e');
      return unreadCountNotifier.value;
    }
  }

  /// Tandai 1 notifikasi sudah dibaca
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_unread': false})
          .eq('id', notificationId);

      if (unreadCountNotifier.value > 0) {
        unreadCountNotifier.value -= 1;
      }
    } catch (e) {
      debugPrint('Error marking admin notification as read: $e');
    }
  }

  /// Tandai seluruh notifikasi admin sudah dibaca
  static Future<void> markAllAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_unread': false})
          .eq('target_role', 'admin')
          .eq('is_unread', true);

      unreadCountNotifier.value = 0;
    } catch (e) {
      debugPrint('Error marking all admin notifications as read: $e');
    }
  }

  /// Hapus 1 notifikasi admin
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      // Refresh unread count
      await countUnread();
    } catch (e) {
      debugPrint('Error deleting admin notification: $e');
    }
  }

  /// Subscribe ke realtime changes untuk notifikasi admin
  static RealtimeChannel? subscribeToAdminNotifications({
    required void Function() onData,
  }) {
    try {
      final channelName = 'admin_notifications_${DateTime.now().millisecondsSinceEpoch}';
      final channel = _client.channel(channelName);

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'target_role',
              value: 'admin',
            ),
            callback: (payload) {
              countUnread();
              onData();
            },
          )
          .subscribe();

      return channel;
    } catch (e) {
      debugPrint('Error subscribing to admin notifications: $e');
      return null;
    }
  }
}

