import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  late GenerativeModel _model;
  final List<Content> _history = [];

  GeminiService({required this.apiKey, String modelName = 'gemini-2.5-flash'}) {
    _initModel(modelName);
  }

  void _initModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  void updateModel(String modelName) {
    _initModel(modelName);
  }

  Stream<String> sendMessageStream(String message) async* {
    final content = Content.text(message);

    // Create a chat session with the existing history
    final chat = _model.startChat(history: _history);

    final response = chat.sendMessageStream(content);

    String fullResponse = '';
    await for (final chunk in response) {
      if (chunk.text != null) {
        fullResponse += chunk.text!;
        yield chunk.text!;
      }
    }

    // Update history after full response is received
    _history.add(content);
    _history.add(Content.model([TextPart(fullResponse)]));
  }

  void clearHistory() {
    _history.clear();
  }
}
