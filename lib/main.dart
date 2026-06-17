import 'package:flutter/material.dart';
import 'package:yojana_mitra/features/onboarding/screens/login_screen.dart';
import 'package:yojana_mitra/features/home/screens/home_screen.dart';
import 'package:yojana_mitra/features/schemes/screens/schemes_screen.dart';
import 'package:yojana_mitra/features/profile/screens/profile_screen.dart';
import 'package:yojana_mitra/features/documents/screens/documents_screen.dart';
import 'package:yojana_mitra/features/chat/screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yojana Mitra',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/schemes': (context) => const SchemesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/documents': (context) => const DocumentsScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}