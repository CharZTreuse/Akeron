// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDytLSTi18linMp9tnzA3svxsfZhqwgLxk',
    appId: '1:482383448329:web:9d5e33e8bfdd2b8074ebd8',
    messagingSenderId: '482383448329',
    projectId: 'esp32-firebase-demo-4b148',
    authDomain: 'esp32-firebase-demo-4b148.firebaseapp.com',
    databaseURL: 'https://esp32-firebase-demo-4b148-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'esp32-firebase-demo-4b148.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpNYQV2DiWOZ1micWNAigcx6nA5Qgeyyw',
    appId: '1:482383448329:android:673597f456e9430a74ebd8',
    messagingSenderId: '482383448329',
    projectId: 'esp32-firebase-demo-4b148',
    databaseURL: 'https://esp32-firebase-demo-4b148-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'esp32-firebase-demo-4b148.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzZe6pJ0PGnTmmSCwOo9Fi_2_FS076e0M',
    appId: '1:482383448329:ios:d889e796eb79f56574ebd8',
    messagingSenderId: '482383448329',
    projectId: 'esp32-firebase-demo-4b148',
    databaseURL: 'https://esp32-firebase-demo-4b148-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'esp32-firebase-demo-4b148.appspot.com',
    iosClientId: '482383448329-vft27j5ke4oqc6biaem6gudmjlv2681r.apps.googleusercontent.com',
    iosBundleId: 'com.example.realtime',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzZe6pJ0PGnTmmSCwOo9Fi_2_FS076e0M',
    appId: '1:482383448329:ios:1196118f8734f28074ebd8',
    messagingSenderId: '482383448329',
    projectId: 'esp32-firebase-demo-4b148',
    databaseURL: 'https://esp32-firebase-demo-4b148-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'esp32-firebase-demo-4b148.appspot.com',
    iosClientId: '482383448329-rsi0empfejh1k88eeht3b5qcgrgk94l4.apps.googleusercontent.com',
    iosBundleId: 'com.example.realtime.RunnerTests',
  );
}
