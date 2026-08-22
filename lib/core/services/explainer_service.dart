import 'dart:math';
import 'groq_client.dart';

/// Which language the explanation should come back in.
enum ExplainerLanguage { hindi, english }

/// Thrown when an explanation could not be produced (network, API, etc.).
class ExplainerException implements Exception {
  final String message;
  ExplainerException(this.message);
  @override
  String toString() => 'ExplainerException: $message';
}

/// Contract for "explain this in simple words" — kept small on purpose so
/// the backend can be swapped without touching any UI code.
abstract class ExplainerService {
  Future<String> explain({
    required String content,
    required ExplainerLanguage language,
  });
}

/// Default instance used by the widget when no service is explicitly
/// passed in. Backed by Groq.
final ExplainerService defaultExplainerService = GroqExplainerService();

// ─────────────────────────────────────────────────────────────────────────
//  REAL IMPLEMENTATION — Groq
// ─────────────────────────────────────────────────────────────────────────
class GroqExplainerService implements ExplainerService {
  final GroqClient _client = GroqClient();

  @override
  Future<String> explain({
    required String content,
    required ExplainerLanguage language,
  }) async {
    final langInstruction = language == ExplainerLanguage.hindi
        ? 'Reply only in simple, friendly Hindi (Devanagari script). No English sentences, though common terms like "Aadhaar" or scheme names can stay as-is.'
        : 'Reply only in simple, friendly English.';
    final systemInstruction =
        'You explain government-scheme text to Indian farmers who may have '
        'little formal education. Explain the given text step-by-step, in '
        'extremely simple words, as if to someone hearing this for the '
        'first time. Use short bullet points. Keep the whole answer under '
        '120 words. Do not invent facts that are not in the given text. '
        '$langInstruction';
    try {
      final reply = await _client.generate(
        systemInstruction: systemInstruction,
        history: [
          {'role': 'user', 'text': content},
        ],
      );
      return reply;
    } on GroqApiException catch (e) {
      throw ExplainerException(e.code);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
//  OFFLINE FALLBACK — kept for local testing / if no API key is set.
//  Not used by default; wire it back in by pointing
//  `defaultExplainerService` above at `MockExplainerService()`.
// ─────────────────────────────────────────────────────────────────────────
class MockExplainerService implements ExplainerService {
  final Random _random = Random();
  @override
  Future<String> explain({required String content, required ExplainerLanguage language}) async {
    await Future.delayed(Duration(milliseconds: 700 + _random.nextInt(700)));
    final short = content.trim().length > 220 ? '${content.trim().substring(0, 220)}…' : content.trim();
    return language == ExplainerLanguage.hindi
        ? 'सरल भाषा में:\n\n• यह इस बारे में है: "$short"\n• (offline demo mode — real explanation ke liye API key check karein)'
        : 'In simple words:\n\n• This is about: "$short"\n• (offline demo mode — check API key for real explanations)';
  }
}