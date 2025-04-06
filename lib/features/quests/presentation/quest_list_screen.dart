//
// Dart file for displaying a list of quests.
//
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/quests/presentation/quest_detail_screen.dart';
import '../../mental_health/presentation/chat_screen.dart';
import '../../mental_health/provider/chat_provider.dart';
import '../data/models/quest_model.dart';
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
          
          if (quest.type == QuestType.mentalHealth) {
            final chatProvider = context.read<ChatProvider>();
            await chatProvider.startSession(quest);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuestDetailScreen(quest: quest)),
              );
            }
          } else {
            await provider.startQuest(quest);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestDetailScreen(quest: quest),
                ),
              );
            }
  }
},
        ),
      ),
    );
  }
}