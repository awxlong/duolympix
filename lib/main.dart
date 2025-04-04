import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'features/quests/presentation/quest_list_screen.dart';
import 'features/quests/provider/quest_provider.dart';
import 'services/location_service.dart';
import 'features/quests/data/repositories/local_quest_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
                ChangeNotifierProvider(
                  create: (_) => QuestProvider(
                    repository: LocalQuestRepository(),
                    locationService: LocationService(),
                    )..initialize(),
                ),
                      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Leveling',
      theme: AppTheme.darkTheme,
      home: const QuestListScreen(), // by default show all possible quests. change this in the future to emulate Solo Leveling
    );
  }
}