import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  bool isOnAuthScreen() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      print('[DEBUG] NavigationService: No context available');
      return false;
    }

    final route = ModalRoute.of(context);
    if (route == null) {
      print('[DEBUG] NavigationService: No route available');
      return false;
    }

    final routeName = route.settings.name;
    print('[DEBUG] NavigationService: Current route: $routeName');

    // Check for login/signup routes
    return routeName == 'LoginScreen' ||
        routeName == 'SignupScreen' ||
        routeName == '/login' ||
        routeName == '/signup';
  }

  String? getCurrentRoute() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;
    return ModalRoute.of(context)?.settings.name;
  }
}
