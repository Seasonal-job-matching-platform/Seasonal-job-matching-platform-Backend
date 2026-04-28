import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'notifications': 'Notifications',
      'noNotificationsYet': 'No notifications yet',
      'clearAllNotifications': 'Clear All Notifications',
      'areYouSureClearAll': 'Are you sure you want to clear all notifications?',
      'cancel': 'Cancel',
      'clearAll': 'Clear All',
      'retry': 'Retry',
      'error': 'Error',
      'pleaseLogInToView': 'Please log in to view notifications',
      'settings': 'Settings',
      'profile': 'Profile',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout from your account?',
      'emailNotifications': 'Email Notifications',
      'receiveEmailUpdates': 'Receive updates about your applications',
      'language': 'Language',
      'home': 'Home',
      'exploreJobs': 'Explore Jobs',
      'myApplications': 'My Applications',
      'applied': 'Applied',
      'editProfile': 'Edit Profile',
      'personalDetails': 'Personal Details',
      'account': 'Account',
      'phone': 'Phone',
      'nationality': 'Nationality',
      'interests': 'Interests',
      'notSet': 'Not set',
      'loggingOut': 'Logging out...',
    },
    'ar': {
      'notifications': 'الإشعارات',
      'noNotificationsYet': 'لا توجد إشعارات بعد',
      'clearAllNotifications': 'مسح جميع الإشعارات',
      'areYouSureClearAll': 'هل أنت متأكد من أنك تريد مسح جميع الإشعارات؟',
      'cancel': 'إلغاء',
      'clearAll': 'مسح الكل',
      'retry': 'إعادة المحاولة',
      'error': 'خطأ',
      'pleaseLogInToView': 'يرجى تسجيل الدخول لعرض الإشعارات',
      'settings': 'الإعدادات',
      'profile': 'الملف الشخصي',
      'logout': 'تسجيل الخروج',
      'logoutConfirm': 'هل أنت متأكد من أنك تريد تسجيل الخروج من حسابك؟',
      'emailNotifications': 'إشعارات البريد الإلكتروني',
      'receiveEmailUpdates': 'تلقي التحديثات حول طلباتك',
      'language': 'اللغة',
      'home': 'الرئيسية',
      'exploreJobs': 'وظائف',
      'myApplications': 'طلباتي',
      'applied': 'تقدمت',
      'editProfile': 'تعديل الملف',
      'personalDetails': 'البيانات الشخصية',
      'account': 'الحساب',
      'phone': 'الهاتف',
      'nationality': 'الجنسية',
      'interests': 'اهتمامات',
      'notSet': 'غير محدد',
      'loggingOut': 'جاري تسجيل الخروج...',
    },
  };

  String _t(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;

  String get notifications => _t('notifications');
  String get noNotificationsYet => _t('noNotificationsYet');
  String get clearAllNotifications => _t('clearAllNotifications');
  String get areYouSureClearAll => _t('areYouSureClearAll');
  String get cancel => _t('cancel');
  String get clearAll => _t('clearAll');
  String get retry => _t('retry');
  String get error => _t('error');
  String get pleaseLogInToView => _t('pleaseLogInToView');
  String get settings => _t('settings');
  String get profile => _t('profile');
  String get logout => _t('logout');
  String get logoutConfirm => _t('logoutConfirm');
  String get emailNotifications => _t('emailNotifications');
  String get receiveEmailUpdates => _t('receiveEmailUpdates');
  String get language => _t('language');
  String get home => _t('home');
  String get exploreJobs => _t('exploreJobs');
  String get myApplications => _t('myApplications');
  String get applied => _t('applied');
  String get editProfile => _t('editProfile');
  String get personalDetails => _t('personalDetails');
  String get account => _t('account');
  String get phone => _t('phone');
  String get nationality => _t('nationality');
  String get interests => _t('interests');
  String get notSet => _t('notSet');
  String get loggingOut => _t('loggingOut');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}