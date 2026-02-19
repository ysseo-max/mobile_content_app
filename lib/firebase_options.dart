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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_QwviH3iHJkmYalRjJx7vYgclNdUYOhc',
    appId: '1:924939408824:web:cb5b146571ee7cd2ac6b4d',
    messagingSenderId: '924939408824',
    projectId: 'rebeauty-photos',
    authDomain: 'rebeauty-photos.firebaseapp.com',
    storageBucket: 'rebeauty-photos.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBx5uh4lXsAA2TF1naZLG80FRGPNVSTQ0A',
    appId: '1:924939408824:android:b1320f81bcaf932bac6b4d',
    messagingSenderId: '924939408824',
    projectId: 'rebeauty-photos',
    storageBucket: 'rebeauty-photos.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWrNoTVnPbXF8-TnGlJ4CvYHA1zfWhcZc',
    appId: '1:924939408824:ios:f50be1839464c97dac6b4d',
    messagingSenderId: '924939408824',
    projectId: 'rebeauty-photos',
    storageBucket: 'rebeauty-photos.firebasestorage.app',
    iosBundleId: 'com.mobilecontent.mobileContent',
  );
}
