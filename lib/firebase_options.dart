import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// File cấu hình Firebase mặc định.
/// Bạn có thể thay thế các thông số bên dưới bằng thông số từ Firebase Console
/// của dự án bạn (Project Settings > General > Your apps).
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
      default:
        return web;
    }
  }

  // Cấu hình Web (Chạy trên trình duyệt Chrome)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_DEMO_KEY_REPLACE_WITH_YOURS',
    appId: '1:123456789012:web:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'thigk-danentang-firebase',
    authDomain: 'thigk-danentang-firebase.firebaseapp.com',
    storageBucket: 'thigk-danentang-firebase.appspot.com',
  );

  // Cấu hình Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_DEMO_KEY_REPLACE_WITH_YOURS',
    appId: '1:123456789012:android:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'thigk-danentang-firebase',
    storageBucket: 'thigk-danentang-firebase.appspot.com',
  );

  // Cấu hình iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_DEMO_KEY_REPLACE_WITH_YOURS',
    appId: '1:123456789012:ios:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'thigk-danentang-firebase',
    storageBucket: 'thigk-danentang-firebase.appspot.com',
    iosBundleId: 'com.example.thigkdanentang',
  );
}
