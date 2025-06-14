import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatRepository {
  static const String _baseUrl = 'http://10.0.2.2:11434'; // 'http://10.0.2.2:11434' for android emulator
  // static const String _baseUrl = 'http://localhost:11434'; // For iOS simulator
  // static const String _baseUrl = 'http://<your-local-ip>:11434'; // For physical device
  final String _model = 'deepseek-r1:8b';
  // Add this constant
  static const String _systemPrompt = """
    You are a therapist trained in Cognitive Behavioral Therapy (CBT). Your goal is to:
    1. Help identify negative thought patterns
    2. Guide reframing into positive ones
    3. Ask clarifying questions when needed
    4. Provide evidence-based CBT techniques
    Respond in a compassionate, non-judgmental tone. Keep responses under 3 sentences.
    """;
  Future<String> sendMessage(String message) async {

    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': message}
        ],
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message']['content'];
    }
    throw Exception('Failed to get response: ${response.statusCode}');
  }

  Stream<String> streamMessage(String message) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl/api/chat'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': message}],
        'stream': true,
      });

    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    await for (final chunk in stream) {
      final lines = LineSplitter.split(chunk);
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final json = jsonDecode(line);
          yield json['message']['content'];
        } catch (e) {
          yield '[Error parsing response]';
        }
      }
    }
  }
}