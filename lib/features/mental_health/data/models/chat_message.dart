/// Entity representing a chat message in a conversation with a chatbot
library;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String thinkingProcess;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.thinkingProcess = '',
  }) : timestamp = timestamp ?? DateTime.now();
}