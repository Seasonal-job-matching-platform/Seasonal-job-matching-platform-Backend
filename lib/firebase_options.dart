import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can re-run `flutterfire configure` to do that.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can re-run `flutterfire configure` to do that.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder-web',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seasonal-job-matching-platform',
    authDomain: 'seasonal-job-matching-platform.firebaseapp.com',
    storageBucket: 'seasonal-job-matching-platform.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAc6oKRGN-DZAO8xACZbcPD29tHSMr1Fy4',
    appId: '1:616655058642:android:49797b4516387592c5df0b',
    messagingSenderId: '616655058642',
    projectId: 'seasonal-job-matching-platform',
    storageBucket: 'seasonal-job-matching-platform.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCgPHhzgwSZLygMxcXS-toXhF5PvoXd48',
    appId: '1:616655058642:ios:ab00cb9e6a3208efc5df0b',
    messagingSenderId: '616655058642',
    projectId: 'seasonal-job-matching-platform',
    storageBucket: 'seasonal-job-matching-platform.firebasestorage.app',
    iosBundleId: 'com.example.jobSeeker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSy-placeholder-macos',
    appId: '1:000000000000:macos:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'seasonal-job-matching-platform',
    storageBucket: 'seasonal-job-matching-platform.appspot.com',
    iosBundleId: 'com.example.jobSeeker',
  );
}