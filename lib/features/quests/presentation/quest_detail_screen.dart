//
// Dart file for displaying the detail of each quest.
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:solo_leveling/features/quests/presentation/quest_list_screen.dart';
// import 'package:solo_leveling/features/quests/presentation/widgets/quest_card.dart';
import '../provider/quest_provider.dart';
import 'widgets/quest_progress.dart';
import '../../quests/data/models/quest_model.dart';
import 'widgets/timer_display.dart';


class QuestDetailScreen extends StatefulWidget {
  final Quest quest;
  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  bool _showCompletion = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestProvider>(context);
    final isCompleted = provider.completedQuests.contains(widget.quest);

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
            : _buildActiveQuestScreen(provider, widget.quest),
      ),
    );
  }

  Widget _buildActiveQuestScreen(QuestProvider provider, Quest quest) {
    return Column(
      children: [
        TimerDisplay(duration: provider.elapsedTime),
        const SizedBox(height: 20),
        QuestProgress(
          quest: quest,
          progress: _calculateProgress(quest, provider),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await provider.completeQuest();
            setState(() => _showCompletion = true);
          },
          child: const Text('Complete Quest'),
        ),
        if (provider.errorMessage != null)
          Text('Error: ${provider.errorMessage}',
            style: const TextStyle(color: Colors.red)),
      ],
    );
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

  double _calculateProgress(Quest quest, QuestProvider provider) {
    if (quest.type == QuestType.running) {
      final distanceProgress = provider.currentDistance / quest.targetDistance!;
      final timeProgress = provider.elapsedTime.inSeconds / 
                          quest.targetDuration!.inSeconds;
      return (distanceProgress + timeProgress) / 2;
    }
    return provider.elapsedTime.inSeconds / quest.targetDuration!.inSeconds;
  }
}