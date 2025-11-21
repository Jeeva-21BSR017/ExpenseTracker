// This is a PLACEHOLDER file to stop compilation errors.
// You must run 'flutterfire configure' in your terminal to generate the real file
// that connects to your specific Firebase project.

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
        return windows;
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

  // PLACEHOLDER VALUES - THESE WILL NOT WORK FOR REAL LOGIN

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUrH2ONblkz1evrVN186m4DzV7AXRxRPw',
    appId: '1:5382402056:android:1fad4bcd4f39c099a1e1bd',
    messagingSenderId: '5382402056',
    projectId: 'expensetracker-733cd',
    storageBucket: 'expensetracker-733cd.firebasestorage.app',
  );

  // Run 'flutterfire configure' to get your real keys.

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhfyrFEYc188uiwwg4EacE2TbzxjGodjY',
    appId: '1:5382402056:ios:f0b27ec817841200a1e1bd',
    messagingSenderId: '5382402056',
    projectId: 'expensetracker-733cd',
    storageBucket: 'expensetracker-733cd.firebasestorage.app',
    iosBundleId: 'com.example.expensetracker',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0vKPJ9CeLxuEiqbLsl-zQ4hJpPeryRQw',
    appId: '1:5382402056:web:5e3939ef385fc15ea1e1bd',
    messagingSenderId: '5382402056',
    projectId: 'expensetracker-733cd',
    authDomain: 'expensetracker-733cd.firebaseapp.com',
    storageBucket: 'expensetracker-733cd.firebasestorage.app',
    measurementId: 'G-6W6TNP6WLV',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAhfyrFEYc188uiwwg4EacE2TbzxjGodjY',
    appId: '1:5382402056:ios:f0b27ec817841200a1e1bd',
    messagingSenderId: '5382402056',
    projectId: 'expensetracker-733cd',
    storageBucket: 'expensetracker-733cd.firebasestorage.app',
    iosBundleId: 'com.example.expensetracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB0vKPJ9CeLxuEiqbLsl-zQ4hJpPeryRQw',
    appId: '1:5382402056:web:1637c576ddeba781a1e1bd',
    messagingSenderId: '5382402056',
    projectId: 'expensetracker-733cd',
    authDomain: 'expensetracker-733cd.firebaseapp.com',
    storageBucket: 'expensetracker-733cd.firebasestorage.app',
    measurementId: 'G-QDNLM2DR36',
  );

}