import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _localeKey = 'app_locale';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Locale build() {
    return const Locale('en');
  }

  Future<void> init() async {
    try {
      final saved = await _storage.read(key: _localeKey);
      if (saved != null && (saved == 'en' || saved == 'ar')) {
        state = Locale(saved);
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> setLocale(String languageCode) async {
    await _storage.write(key: _localeKey, value: languageCode);
    state = Locale(languageCode);
  }

  bool get isRtl => state.languageCode == 'ar';
}