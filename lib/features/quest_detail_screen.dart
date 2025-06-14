//
// Dart file for displaying the detail of each quest.
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/mental_health/presentation/widgets/typing_indicator.dart';
import 'mental_health/presentation/widgets/chat_bubble.dart';
import 'mental_health/provider/chat_provider.dart';
import 'quests/provider/quest_provider.dart';
import 'quests/presentation/widgets/quest_progress.dart';
import 'quests/data/models/quest_model.dart';
import 'quests/presentation/widgets/timer_display.dart';

class QuestDetailScreen extends StatefulWidget {
  final Quest quest;
  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}


class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _showCompletion = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final chatProvider = widget.quest.type == QuestType.mentalHealth
        ? Provider.of<ChatProvider>(context)
        : null;
    final isCompleted = questProvider.completedQuests.contains(widget.quest);

    if (isCompleted && !_showCompletion) {
      Future.delayed(Duration.zero, () {
        setState(() => _showCompletion = true);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.quest.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showCompletion 
            ? _buildCompletionScreen(widget.quest)
            : (widget.quest.type == QuestType.mentalHealth
                ? _buildChatInterface(chatProvider!, questProvider)
                : _buildPhysicalQuestScreen(questProvider, widget.quest)),
      ),
    );
  }

  
  
  Widget _buildPhysicalQuestScreen(QuestProvider provider, Quest quest) {
    return Column(
      children: [
        TimerDisplay(
          duration: provider.elapsedTime,
          targetDuration: quest.targetDuration,
        ),
        const SizedBox(height: 20),
        QuestProgress(
          quest: quest,
          progress: _calculateProgress(quest, provider, null),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _handleQuestCompletion(provider),
          child: const Text('Complete Quest'),
        ),
        if (provider.errorMessage != null)
          Text('Error: ${provider.errorMessage}',
            style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildChatInterface(ChatProvider chatProvider, QuestProvider questProvider) {
    return Column(
      children: [
        TimerDisplay(
          duration: chatProvider.elapsedTime,
          targetDuration: widget.quest.targetDuration,
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                reverse: true,
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messages.reversed.toList()[index];
                  return ChatBubble(
                    message: message.text,
                    isUser: message.isUser,
                  );
                },
              ),
              if (chatProvider.isLoading) _buildTypingIndicator(),
            ],
          ),
        ),
        _buildChatInput(chatProvider),
        ElevatedButton(
          onPressed: chatProvider.isSessionComplete 
              ? () => _handleQuestCompletion(questProvider) 
              : null,
          child: const Text('Complete Quest'),
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return const TypingIndicator();
  }


  Widget _buildChatInput(ChatProvider provider) {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    // final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _sendMessage(value, _messageController, provider),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_messageController.text, _messageController, provider),
          ),
        ],
      ),
    );
  }
  void _sendMessage(String text, TextEditingController controller, ChatProvider provider) {
    if (text.trim().isEmpty) return;
    controller.clear();
    provider.sendMessage(text);
  }

  double _calculateProgress(Quest quest, QuestProvider provider, ChatProvider? chatProvider) {
    if (quest.type == QuestType.running) {
      final distanceProgress = provider.currentDistance / quest.targetDistance!;
      final timeProgress = provider.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
      return (distanceProgress + timeProgress) / 2;
    } else if (quest.type == QuestType.mentalHealth) {
      return chatProvider!.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
    }
    return provider.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
  }


  Widget _buildCompletionScreen(Quest quest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text('+${quest.xpReward} XP',
          style: const TextStyle(fontSize: 24, color: Colors.amber)),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Quests'),
        ),
      ],
    );
  }
  
  Future<void> _handleQuestCompletion(QuestProvider provider) async {
    await provider.completeQuest();
    setState(() => _showCompletion = true);
  }

}