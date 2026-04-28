import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Function(RemoteMessage)? _onMessageCallback;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;

  Future<void> initialize() async {
    final permission = await _firebaseMessaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.authorized) {
      print('[NotificationService] Permission granted');
    } else {
      print(
        '[NotificationService] Permission denied: ${permission.authorizationStatus}',
      );
    }

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageOpenedApp,
    );
  }

  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('[NotificationService] FCM Token: $token');
      return token;
    } catch (e) {
      print('[NotificationService] Error getting token: $e');
      return null;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print(
      '[NotificationService] Foreground message: ${message.notification?.title}',
    );
    _onMessageCallback?.call(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print(
      '[NotificationService] App opened from notification: ${message.notification?.title}',
    );
    _onMessageCallback?.call(message);
  }

  void onMessage(Function(RemoteMessage) callback) {
    _onMessageCallback = callback;
  }

  void onMessageOpened(Function(RemoteMessage) callback) {
    _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      callback,
    );
  }

  Future<void> onBackgroundMessage(RemoteMessage message) async {
    print(
      '[NotificationService] Background message: ${message.notification?.title}',
    );
  }

  Map<String, dynamic>? parseApplicationStatusNotification(
    RemoteMessage message,
  ) {
    final data = message.data;
    if (data['type'] == 'APPLICATION_STATUS') {
      return {
        'status': data['status'],
        'jobTitle': data['jobTitle'],
        'applicationId': data['applicationId'],
      };
    }
    return null;
  }
}
