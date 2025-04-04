//
// Dart file for displaying a list of quests.
//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/quests/presentation/quest_detail_screen.dart';
import '../provider/quest_provider.dart';
import 'widgets/quest_card.dart';

class QuestListScreen extends StatelessWidget {
  const QuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quests')),
      body: ListView.builder(
        itemCount: provider.availableQuests.length,
        itemBuilder: (context, index) => QuestCard(
          quest: provider.availableQuests[index],
          onStart: () async {
          final quest = provider.availableQuests[index];
          await provider.startQuest(quest);
          if (context.mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestDetailScreen(quest: quest),
              ),
            );
          }
        },
        ),
      ),
    );
  }
}