import 'package:flutter/material.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onStart;

  const QuestCard({super.key, required this.quest, this.onStart});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onStart,
      child: Card(
        child: ListTile(
          leading: Icon(quest.icon),
          title: Text(quest.title),
          subtitle: Text(quest.description),
          trailing: IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: onStart,
          ),
        ),
      ),
    );
  }
}
