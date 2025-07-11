import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String thinkingProcess;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.thinkingProcess = '',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color.fromARGB(255, 0, 140, 255) : const Color.fromARGB(255, 255, 0, 123),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message),
          ),
          if (!isUser && thinkingProcess.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FloatingActionButton.extended(
                heroTag: 'thoughts_${message.hashCode}', // Provide a unique hero tag
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Thoughts'),
                        content: Text(thinkingProcess),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                label: const Text('Thoughts'),
                icon: const Icon(Icons.info),
              ),
            ),
        ],
      ),
    );
  }
}