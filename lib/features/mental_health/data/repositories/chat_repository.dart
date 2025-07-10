// lib/features/mental_health/data/repositories/chat_repository.dart
/// Chat Repository - Interface to LLM for conversational capabilities. Currently, a quantized deepsee-r1-8b hosted 
/// with ollama is used:
/// `ollama serve`
/// `ollama run deepseek-r1:8b`
/// Manages communication with a local LLM (Large Language Model) server
/// for providing mental health support through CBT (Cognitive Behavioral Therapy)
/// techniques. Handles message sending, streaming responses, and error handling.
library;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatRepository {
  /// Base URL for the local LLM server
  /// 
  /// Note: Use 'http://10.0.2.2:11434' for Android emulator
  ///       Use device's local IP (e.g., 'http://192.168.0.13:11434') for physical devices
  static const String _baseUrl = 'http://10.0.2.2:11434'; // TODO: update for production
  
  /// LLM model to use for generating responses
  final String _model = 'deepseek-r1:8b'; // TODO: update for production
  
  /// System prompt to guide the LLM's behavior
  /// 
  /// Sets the AI's persona as a CBT therapist, providing guidelines for:
  /// - Identifying negative thought patterns
  /// - Reframing into positive thinking
  /// - Asking clarifying questions
  /// - Using evidence-based CBT techniques
  /// - Maintaining a compassionate, non-judgmental tone
  static const String _systemPrompt = """
    You are a therapist trained in Cognitive Behavioral Therapy (CBT). Your goal is to:
    1. Help identify negative thought patterns
    2. Guide reframing into positive ones
    3. Ask clarifying questions when needed
    4. Provide evidence-based CBT techniques
    Respond in a compassionate, non-judgmental tone. Keep responses under 3 sentences.
    """;

  /// Sends a message to the LLM and returns a single response
  /// 
  /// [message]: User's message to the therapist AI
  /// Returns: The AI's response as a string consisting of 'answer' and 'thought process' <- HARDCODED,
  /// thus may not work for LLMs which don't have CoT as part of their response.
  /// Throws: Exception if request fails or response is invalid
  Future<Map<String, String>> sendMessage(String message) async {
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
      final content = jsonDecode(response.body)['message']['content'];
      final thinkStart = content.indexOf('<think>');
      final thinkEnd = content.indexOf('</think>');
      String thinkingProcess = '';
      String answer = content;

      if (thinkStart != -1 && thinkEnd != -1) {
        thinkingProcess = content.substring(thinkStart + 7, thinkEnd).trim();
        answer = content.replaceAll('<think>\n$thinkingProcess\n</think>', '').trim();
      }

      return {
        'answer': answer,
        'thinkingProcess': thinkingProcess,
      };
    }
    throw Exception('Failed to get response: ${response.statusCode}');
  }

  /// Sends a message to the LLM and streams responses in real-time
  /// 
  /// [message]: User's message to the therapist AI
  /// Returns: A stream of response chunks as they are generated
  /// Handles: Stream parsing, error handling, and line splitting
  Stream<String> streamMessage(String message) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl/api/chat'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': message}
        ],
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