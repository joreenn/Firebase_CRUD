import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError('Firebase Notes is configured for Android.');
    }
    return android;
  }

  // Local Firebase Emulator Suite configuration. FlutterFire CLI can replace
  // this file with options generated for a registered Firebase project.
  static const android = FirebaseOptions(
    apiKey: 'ADemoProjectApiKey000000000000000000000',
    appId: '1:1:android:1',
    messagingSenderId: '1',
    projectId: 'demo-firebase-note',
  );
}
