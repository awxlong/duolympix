import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import '../../quests/presentation/widgets/timer_display.dart';
import '../../quests/provider/quest_provider.dart';
import '../provider/chat_provider.dart';
import 'widgets/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  final Quest quest;
  const ChatScreen({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quest.title),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, _) => TimerDisplay(
              duration: provider.elapsedTime,
              targetDuration: quest.targetDuration,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) => Stack(
                children: [
                  ListView.builder(
                    reverse: true,
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages.reversed.toList()[index];
                      return ChatBubble(
                        message: message.text,
                        isUser: message.isUser,
                      );
                    },
                  ),
                  if (provider.isLoading) _buildTypingIndicator(),
                ],
              ),
            ),
          ),
          _buildInputSection(context),
          _buildCompletionButton(context),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _sendMessage(value, controller, provider),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(controller.text, controller, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionButton(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: provider.isSessionComplete ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: provider.isSessionComplete
                ? () => _completeSession(context)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(width: 8),
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
    );
  }

  void _sendMessage(String text, TextEditingController controller, ChatProvider provider) {
    if (text.trim().isEmpty) return;
    controller.clear();
    provider.sendMessage(text);
  }

  void _completeSession(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    // final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    if (!questProvider.completedQuests.contains(quest)) {
      questProvider.completeQuest();
    }
    Navigator.pop(context);
  }
}