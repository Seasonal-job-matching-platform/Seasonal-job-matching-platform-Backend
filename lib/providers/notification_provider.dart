import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_seeker/models/notification_model.dart';
import 'package:job_seeker/services/notifications_api_service.dart';
import 'package:job_seeker/services/notification_service.dart';
import 'package:job_seeker/providers/auth_provider.dart';

part 'notification_provider.g.dart';

@riverpod
class Notifications extends _$Notifications {
  @override
  Future<List<NotificationModel>> build(int userId) async {
    final apiService = ref.read(notificationsApiServiceProvider);
    
    // Listen to foreground messages
    NotificationService().onMessage((message) {
      ref.invalidateSelf();
    });

    return await apiService.getNotifications(userId);
  }

  Future<void> markAsRead(int notificationId) async {
    final apiService = ref.read(notificationsApiServiceProvider);
    final previousState = state.value;
    
    if (previousState != null) {
      state = AsyncValue.data(
        previousState.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );
    }

    try {
      await apiService.markAsRead(notificationId);
    } catch (e) {
      if (previousState != null) {
        state = AsyncValue.data(previousState);
      }
    }
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final userId = ref.watch(authProvider).userId;
  if (userId == null) return 0;

  final notificationsAsync = ref.watch(notificationsProvider(userId));
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final notificationRefreshProvider = Provider<void Function()>((ref) {
  final userId = ref.watch(authProvider).userId;
  if (userId == null) return () {};

  return () {
    ref.invalidate(notificationsProvider(userId));
  };
});
