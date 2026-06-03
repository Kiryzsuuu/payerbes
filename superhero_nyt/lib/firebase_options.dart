// File ini di-generate otomatis oleh: flutterfire configure
// Jalankan START.bat untuk setup Firebase secara otomatis
// JANGAN edit manual

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.\n'
          'Jalankan START.bat untuk setup Firebase.',
        );
    }
  }

  // Nilai di bawah adalah PLACEHOLDER.
  // Jalankan START.bat → pilih "Setup Firebase" untuk menggantinya dengan nilai asli.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1-tLPli3us2jWbPGDLiGjxmedIQdbqug',
    appId: '1:818865828200:android:08d9b560cc03bed913a6dd',
    messagingSenderId: '818865828200',
    projectId: 'superman-anin-rizky-hawa-adar',
    storageBucket: 'superman-anin-rizky-hawa-adar.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    iosBundleId: 'com.kelompok.superheroNyt',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAKeFgCc5bafayNj8PuzeHZnqjuvql2ePE',
    appId: '1:818865828200:web:5339fecc3064dc4513a6dd',
    messagingSenderId: '818865828200',
    projectId: 'superman-anin-rizky-hawa-adar',
    authDomain: 'superman-anin-rizky-hawa-adar.firebaseapp.com',
    storageBucket: 'superman-anin-rizky-hawa-adar.firebasestorage.app',
    measurementId: 'G-89CD6SG2JZ',
  );
}
