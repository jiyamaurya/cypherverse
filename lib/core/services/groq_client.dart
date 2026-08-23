import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart' as secrets;

/// Thrown when the Groq API call fails for any reason.
class GroqApiException implements Exception {
  final String code;
  GroqApiException(this.code);
  @override
  String toString() => 'GroqApiException: $code';
}

/// Minimal wrapper around Groq's OpenAI-compatible chat completions API.
///
/// The key is normally read from `lib/core/config/secrets.dart` (gitignored,
/// so `flutter run` just works with no extra flags). See
/// `lib/core/config/secrets.example.dart` for setup instructions.
///
/// A `--dart-define=GROQ_API_KEY=your_key` at run time still works too and
/// takes priority, e.g. for CI or a machine without secrets.dart set up.
///
/// Get a free key at https://console.groq.com/keys
class GroqClient {
  static const String _dartDefineKey = String.fromEnvironment('GROQ_API_KEY');
  static String get _apiKey =>
      _dartDefineKey.isNotEmpty ? _dartDefineKey : secrets.groqApiKey;

  // Fast + strong at following language/formatting instructions,
  // handles Hindi/Hinglish well. (llama-3.3-70b-versatile was
  // deprecated by Groq on 17 June 2026 — gpt-oss-120b is the
  // current recommended replacement.)
  static const String _model = 'openai/gpt-oss-120b';

  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  /// Sends [history] (list of {'role': 'user'|'model', 'text': ...})
  /// plus a [systemInstruction] to Groq and returns the text reply.
  Future<String> generate({
    required String systemInstruction,
    required List<Map<String, String>> history,
  }) async {
    if (_apiKey.isEmpty || _apiKey.startsWith('PASTE_')) {
      throw GroqApiException(
        'no_api_key: paste your key into lib/core/config/secrets.dart',
      );
    }

    final messages = [
      {'role': 'system', 'content': systemInstruction},
      ...history.map((m) => {
            // Groq/OpenAI format uses 'assistant', not 'model'.
            'role': m['role'] == 'model' ? 'assistant' : 'user',
            'content': m['text'] ?? '',
          }),
    ];

    final body = {
      'model': _model,
      'messages': messages,
      'temperature': 0.4,
      'max_tokens': 500,
    };

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
    } catch (e) {
      throw GroqApiException('network_error');
    }

    if (response.statusCode == 429) {
      throw GroqApiException('rate_limited');
    }
    if (response.statusCode == 401) {
      throw GroqApiException('invalid_api_key');
    }
    if (response.statusCode == 400) {
      throw GroqApiException('bad_request: ${response.body}');
    }
    if (response.statusCode != 200) {
      throw GroqApiException('server_error_${response.statusCode}');
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = json['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw GroqApiException('empty_response');
      }
      final content = choices[0]['message']?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw GroqApiException('empty_response');
      }
      return content.trim();
    } catch (e) {
      if (e is GroqApiException) rethrow;
      throw GroqApiException('parse_error');
    }
  }
}