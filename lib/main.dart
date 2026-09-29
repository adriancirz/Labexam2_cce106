import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/task_screen.dart';

/// The AppBar title for the application.
/// Default is set to 'Labexam2_Lastname' matching the lab exam specification.
/// You can also set this to 'Labexam2_Ponce' if your instructor prefers your actual surname.
const String kAppTitle = 'Labexam2_Ponce';

void main() async {
  // Ensure that Flutter widget binding is initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Firestore with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

/// The root application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E627C),
          primary: const Color(0xFF0E627C),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F6F8),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const TaskScreen(title: kAppTitle),
    );
  }
}
