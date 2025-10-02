import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:saferoad/app_theme.dart';
import 'package:saferoad/screens/login_screen.dart';
import 'package:saferoad/services/auth_service.dart';
import 'package:saferoad/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRoad',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
