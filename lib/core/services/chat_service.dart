import 'groq_client.dart';

/// One message in the running chat history, in the shape GroqClient wants.
class ChatTurn {
  final String role; // 'user' or 'model'
  final String text;
  ChatTurn(this.role, this.text);
}

/// Wraps GroqClient with the farmer-assistant persona + conversation
/// history, so chat_screen.dart doesn't need to know about prompts at all.
class ChatService {
  final GroqClient _client = GroqClient();

  static const String _systemInstruction =
      'You are "Yojana Mitra AI", a friendly assistant that helps Indian '
      'farmers understand and access government welfare schemes (like '
      'PM-Kisan, Fasal Bima Yojana, Kisan Credit Card, etc). '
      'IMPORTANT — language rule: always reply in the SAME language the '
      'user just wrote their latest message in. '
      'If they wrote in Hindi (Devanagari script, e.g. "मुझे बताओ"), reply '
      'fully in Hindi (Devanagari script). '
      'If they wrote in English (e.g. "tell me"), reply fully in English. '
      'If they wrote in Hinglish (Hindi words in Roman/Latin script, e.g. '
      '"mujhe batao"), reply in that same Hinglish style. '
      'Do not mix scripts within one reply, and do not default to Hinglish '
      'when the user wrote in plain Hindi or plain English — match their '
      'actual language exactly. '
      'Keep the tone of a helpful local CSC center worker talking to a '
      'farmer, in whichever of the three styles applies. '
      'Keep replies short and practical: use bullet points for lists, bold '
      'the important numbers (amounts, deadlines), and end with a helpful '
      'follow-up suggestion when useful. '
      'If you do not have specific data (like the user\'s personal '
      'documents or exact local center addresses), say so honestly instead '
      'of inventing details. Do not use complicated bureaucratic language.';

  /// Sends [userMessage] plus prior [history] to Gemini and returns the
  /// assistant's reply as plain text.
  Future<String> sendMessage({
    required String userMessage,
    required List<ChatTurn> history,
  }) async {
    final apiHistory = [
      ...history.map((t) => {'role': t.role, 'text': t.text}),
      {'role': 'user', 'text': userMessage},
    ];

    try {
      return await _client.generate(
        systemInstruction: _systemInstruction,
        history: apiHistory,
      );
    } on GroqApiException catch (e) {
      if (e.code.startsWith('no_api_key')) {
        return 'API key set nahi hai. `lib/core/config/secrets.dart` file kholkar apni Groq key paste karein.';
      }
      switch (e.code) {
        case 'network_error':
          return 'Internet connection check karein — reply nahi mil paaya.';
        case 'rate_limited':
          return 'Thoda rukiye, bahut zyada requests ja rahi hain. Kuch second baad phir try karein.';
        case 'invalid_api_key':
          return 'API key galat hai ya expire ho gayi hai. Groq console (console.groq.com/keys) se naya key generate karein.';
        default:
          return 'Maaf kijiye, abhi jawab nahi mil paaya. (Error: ${e.code})\nDobara try karein.';
      }
    }
  }
}