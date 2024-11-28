import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miragem_firebase/firebase_options.dart';
import 'package:miragem_firebase/views/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(
    home: AuthPage(),
    debugShowCheckedModeBanner: false,
  ));
}
