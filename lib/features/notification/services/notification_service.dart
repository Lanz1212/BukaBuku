import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Global notifier for whether the user has unread notifications
  static final ValueNotifier<bool> hasUnreadNotifier = ValueNotifier<bool>(
    false,
  );

  /// Check whether current user has any unread notifications
  static Future<bool> checkHasUnreadNotifications() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        hasUnreadNotifier.value = false;
        return false;
      }

      final response = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_unread', true)
          .limit(1);

      final hasUnread = (response as List<dynamic>).isNotEmpty;
      hasUnreadNotifier.value = hasUnread;
      return hasUnread;
    } catch (e) {
      debugPrint('Error checking unread notifications: $e');
      return hasUnreadNotifier.value;
    }
  }

  /// Fetch notifications for the current authenticated user from Supabase.
  static Future<List<NotificationModel>> fetchNotifications({
    NotificationCategory? category,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        hasUnreadNotifier.value = false;
        return [];
      }

      var query = _client.from('notifications').select().eq('user_id', user.id);

      if (category != null && category != NotificationCategory.all) {
        final catStr = category == NotificationCategory.promo
            ? 'promo'
            : 'order';
        query = query.eq('category', catStr);
      }

      final response = await query.order('created_at', ascending: false);
      final list = response as List<dynamic>;

      final models = list
          .map(
            (row) =>
                NotificationModel.fromSupabase(row as Map<String, dynamic>),
          )
          .toList();

      if (category == null || category == NotificationCategory.all) {
        hasUnreadNotifier.value = models.any((n) => n.isUnread);
      }

      return models;
    } catch (e) {
      debugPrint('Error fetching notifications from Supabase: $e');
      return [];
    }
  }

  /// Mark a single notification as read in database.
  static Future<void> markAsRead(String notificationId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client
          .from('notifications')
          .update({'is_unread': false})
          .eq('id', notificationId)
          .eq('user_id', user.id);

      await checkHasUnreadNotifications();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications for the current user as read.
  static Future<void> markAllAsRead() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client
          .from('notifications')
          .update({'is_unread': false})
          .eq('user_id', user.id)
          .eq('is_unread', true);

      hasUnreadNotifier.value = false;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Subscribe to realtime changes on user's notifications.
  static RealtimeChannel? subscribeToNotifications({
    required String userId,
    required void Function() onData,
  }) {
    try {
      final channelName =
          'user_notifications_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final channel = _client.channel(channelName);

      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              onData();
            },
          )
          .subscribe();

      return channel;
    } catch (e) {
      debugPrint('Error subscribing to notifications: $e');
      return null;
    }
  }
}
