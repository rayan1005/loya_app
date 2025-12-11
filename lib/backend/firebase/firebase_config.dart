import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDAzQDo2Ju3tN-ilDBzlTfcJcSAOcyT6A0",
            authDomain: "loya-app-ziqygx.firebaseapp.com",
            projectId: "loya-app-ziqygx",
            storageBucket: "loya-app-ziqygx.firebasestorage.app",
            messagingSenderId: "900836887479",
            appId: "1:900836887479:web:8729789f36f3cec2bcf632"));
  } else {
    await Firebase.initializeApp();
  }
}
