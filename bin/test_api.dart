import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyDO-dBI-bQxHiy7FO2omEWPPHikwZ_jWaE';
  final client = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  try {
    // Note: The google_generative_ai package might not expose listModels directly on the GenerativeModel class
    // but we can try to see if there's a workaround or a different way.
    // Actually, let's just try the most robust model names.
    print('Testing API Key access...');
    final response = await client.generateContent([Content.text('hi')]);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error caught: $e');
  }
}
