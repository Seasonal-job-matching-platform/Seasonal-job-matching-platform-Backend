import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/core/dio_provider.dart';
import 'package:job_seeker/endpoints.dart';
import 'package:job_seeker/models/notification_model.dart';

final notificationsApiServiceProvider = Provider<NotificationsApiService>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return NotificationsApiService(dio);
});

class NotificationsApiService {
  final Dio _dio;

  NotificationsApiService(this._dio);

  Future<void> registerToken({
    required int userId,
    required String token,
    required String deviceType,
  }) async {
    try {
      await _dio.post(
        NOTIFICATION_TOKEN_REGISTER,
        data: {'userId': userId, 'token': token, 'deviceType': deviceType},
      );
      print('[NotificationsApiService] Token registered successfully');
    } catch (e) {
      print('[NotificationsApiService] Error registering token: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications(int userId) async {
    try {
      final response = await _dio.get(NOTIFICATIONS(userId.toString()));

      // Handle paginated response
      if (response.data is Map && response.data['content'] != null) {
        final List<dynamic> data = response.data['content'] as List<dynamic>;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      // Handle plain list response (fallback)
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      print('[NotificationsApiService] Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.patch('$NOTIFICATIONS_BASE/$notificationId/read');
    } catch (e) {
      print('[NotificationsApiService] Error marking as read: $e');
    }
  }
}
