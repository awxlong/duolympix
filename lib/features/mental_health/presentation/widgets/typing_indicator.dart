


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/chat_provider.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) => AnimatedOpacity(
        opacity: provider.isLoading ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text('Bot is typing...'),
              SizedBox(width: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}