import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// File cấu hình Firebase của dự án thigk-danentang
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
    apiKey: 'AIzaSyCopaooMjw2EWlwuGKG5pBQZkYIq7r0soc',
    appId: '1:541022894071:web:9b5ebd9e19a9bd43cd60f2',
    messagingSenderId: '541022894071',
    projectId: 'thigk-danentang',
    authDomain: 'thigk-danentang.firebaseapp.com',
    storageBucket: 'thigk-danentang.firebasestorage.app',
    measurementId: 'G-T2L5F7LDQ5',
  );

  // Cấu hình Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCopaooMjw2EWlwuGKG5pBQZkYIq7r0soc',
    appId: '1:541022894071:web:9b5ebd9e19a9bd43cd60f2',
    messagingSenderId: '541022894071',
    projectId: 'thigk-danentang',
    storageBucket: 'thigk-danentang.firebasestorage.app',
  );

  // Cấu hình iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCopaooMjw2EWlwuGKG5pBQZkYIq7r0soc',
    appId: '1:541022894071:web:9b5ebd9e19a9bd43cd60f2',
    messagingSenderId: '541022894071',
    projectId: 'thigk-danentang',
    storageBucket: 'thigk-danentang.firebasestorage.app',
    iosBundleId: 'com.example.thigkdanentang',
  );
}
