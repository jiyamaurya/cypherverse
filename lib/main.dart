import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yojana_mitra/firebase_options.dart';
import 'package:yojana_mitra/features/onboarding/screens/login_screen.dart';
import 'package:yojana_mitra/features/home/screens/home_screen.dart';
import 'package:yojana_mitra/features/schemes/screens/schemes_screen.dart';
import 'package:yojana_mitra/features/profile/screens/profile_screen.dart';
import 'package:yojana_mitra/features/documents/screens/documents_screen.dart';
import 'package:yojana_mitra/features/chat/screens/chat_screen.dart';
import 'package:yojana_mitra/features/profile_setup/screens/profile_setup_screen.dart';
import 'package:yojana_mitra/features/schemes/screens/scheme_detail_screen.dart';
import 'package:yojana_mitra/core/logic/scheme_matcher.dart';
import 'package:yojana_mitra/core/state/profile_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load GROQ_API_KEY (and any other secrets) from the .env file so the
  // key never needs to be passed via --dart-define on every run.
  await dotenv.load(fileName: '.env');

  // Initialize Firebase before running the app. Uses the generated
  // DefaultFirebaseOptions for the current platform.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase fails to initialize, log the error but continue — the
    // app will show errors when attempting Firebase operations.
    // (Don't rethrow so runApp still executes.)
    // ignore: avoid_print
    print('Firebase initialization failed: $e');
  }

  // Load any previously-saved profile before the app starts, so screens
  // that depend on it (schemes, documents, home) have real data on first
  // frame instead of a placeholder after every refresh.
  await ProfileStore.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yojana Mitra',
      debugShowCheckedModeBanner: false,
      initialRoute: ProfileStore.instance.hasProfile ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/schemes': (context) => const SchemesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/documents': (context) => const DocumentsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/scheme-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is MatchResult) {
            return SchemeDetailScreen(result: args);
          }
          return const Scaffold(
            body: Center(child: Text('No scheme data provided')),
          );
        },
      },
    );
  }
}