import 'chat_message.dart';
// import 'local_quest_repository.dart';
class ChatSession {
  final DateTime startTime;
  final List<ChatMessage> messages;
  final String sessionId;

  ChatSession({
    required this.sessionId,
    DateTime? startTime,
    List<ChatMessage>? messages,
  })  : startTime = startTime ?? DateTime.now(),
        messages = messages ?? [];

  Duration get elapsed => DateTime.now().difference(startTime);
  bool get isComplete => elapsed.inMinutes >= 1;

  ChatSession copyWith({
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      sessionId: sessionId,
      startTime: startTime,
      messages: messages ?? this.messages,
    );
  }
}