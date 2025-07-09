import 'package:flutter/material.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';

class QuestProgress extends StatelessWidget {
  final Quest quest;
  final double progress;

  const QuestProgress({
    super.key,
    required this.quest,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          minHeight: 15,
        ),
        const SizedBox(height: 8),
        // Update the Text widget:
        Text(
          quest.type == QuestType.distance
              ? 'Distance: ${progress.toStringAsFixed(2)}/${quest.targetDistance} mi\n'
              : '',
        ),
      ],
    );
  }

}

String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }