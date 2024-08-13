import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:komatsu_diagnostic/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCGc3Y1v4-iib5ayywFuunIIttYIhPfb0c",
      appId: "1:612392661218:android:9f0928b7841be33990aebb",
      messagingSenderId: "612392661218",
      projectId: "komatsu-diagnostic",
      storageBucket: "gs://komatsu-diagnostic.appspot.com",
    ),
  );

  runApp(MaterialApp(
    title: "Komatsu Diagnostic",
    home: SplashScreen(),
  ));
}
