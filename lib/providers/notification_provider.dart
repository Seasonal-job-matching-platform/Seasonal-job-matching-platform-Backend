import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/models/notification_model.dart';
import 'package:job_seeker/services/notifications_api_service.dart';
import 'package:job_seeker/providers/auth_provider.dart';

final notificationsProvider =
    FutureProvider.family<List<NotificationModel>, int>((ref, userId) async {
      final apiService = ref.read(notificationsApiServiceProvider);
      return await apiService.getNotifications(userId);
    });

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
