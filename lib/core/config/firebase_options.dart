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
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAzQDo2Ju3tN-ilDBzlTfcJcSAOcyT6A0',
    appId: '1:900836887479:web:8729789f36f3cec2bcf632',
    messagingSenderId: '900836887479',
    projectId: 'loya-app-ziqygx',
    authDomain: 'loya-app-ziqygx.firebaseapp.com',
    storageBucket: 'loya-app-ziqygx.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAzQDo2Ju3tN-ilDBzlTfcJcSAOcyT6A0',
    appId: '1:900836887479:android:PLACEHOLDER',
    messagingSenderId: '900836887479',
    projectId: 'loya-app-ziqygx',
    storageBucket: 'loya-app-ziqygx.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAzQDo2Ju3tN-ilDBzlTfcJcSAOcyT6A0',
    appId: '1:900836887479:ios:08ccdf80abd75ce2bcf632',
    messagingSenderId: '900836887479',
    projectId: 'loya-app-ziqygx',
    storageBucket: 'loya-app-ziqygx.firebasestorage.app',
    iosBundleId: 'com.mycompany.loya',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDAzQDo2Ju3tN-ilDBzlTfcJcSAOcyT6A0',
    appId: '1:900836887479:ios:08ccdf80abd75ce2bcf632',
    messagingSenderId: '900836887479',
    projectId: 'loya-app-ziqygx',
    storageBucket: 'loya-app-ziqygx.firebasestorage.app',
    iosBundleId: 'com.mycompany.loya',
  );
}
