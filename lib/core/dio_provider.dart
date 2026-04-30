import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config.dart';
import 'auth/auth_interceptor.dart';
import 'auth/auth_storage.dart';
import 'auth/auth_dialog_manager.dart';
import 'navigation_service.dart';
import '../providers/auth_provider.dart';

final appConfigProvider = Provider<AppConfig>((_) => const AppConfig.dev());

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final storage = AuthStorage();

  dio.interceptors.add(
    AuthInterceptor(() async {
      final currentState = ref.read(authProvider);
      if (currentState.token != null) {
        return currentState.token;
      }
      return storage.getToken();
    }),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        final requestPath = error.requestOptions.path;
        print(
          '[DEBUG] Interceptor: Received ${error.response?.statusCode} for $requestPath',
        );

        // Skip auth endpoints - they might return 403 during login flow
        if (requestPath.contains('/auth/') ||
            requestPath.contains('/users/login') ||
            requestPath.contains('/users/signup')) {
          print(
            '[DEBUG] Interceptor blocked: Auth endpoint - skipping 403 check',
          );
          handler.next(error);
          return;
        }

        // Check if user is on auth screen - if so, silently handle
        if (NavigationService().isOnAuthScreen()) {
          print('[DEBUG] Interceptor blocked: User is on auth screen');
          handler.next(error);
          return;
        }

        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          print(
            '[DEBUG] Interceptor: ${error.response?.statusCode} detected - checking if already handled',
          );

          // Check if already handled to prevent multiple triggers
          if (AuthDialogManager().isSessionExpiredHandled) {
            print(
              '[DEBUG] Interceptor blocked: Session expired already handled',
            );
            handler.next(error);
            return;
          }

          AuthDialogManager().markSessionExpiredHandled();
          print('[DEBUG] Interceptor: Clearing storage and logging out');
          await storage.clearToken();
          await storage.clearUserId();
          ref.read(authProvider.notifier).logout(sessionExpired: true);
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
