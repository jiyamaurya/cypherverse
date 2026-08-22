import 'package:flutter/material.dart';
import 'features/onboarding/screens/login_screen.dart';
import 'package:yojana_mitra/features/home/screens/home_screen.dart';// ← ADD THIS

class YojanaMitraApp extends StatelessWidget {
  const YojanaMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yojana Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF9F2),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),   // ← ADD THIS
      },
    );
  }
}