import 'package:flutter/material.dart';
import 'package:solo_leveling/features/quests/data/repositories/quest_repository.dart';

import '../models/quest_model.dart';

class LocalQuestRepository implements QuestRepository {
  final List<Quest> _allQuests = [
    const Quest(
      id: 'run-1-mile',
      title: 'Speed Runner',
      type: QuestType.running,
    icon: Icons.directions_run,
      description: 'Run 1 mile in under 5 minutes',
      targetDistance: 1.0,
      targetDuration: Duration(minutes: 5),
      xpReward: 200,
    ),
    const Quest(
      id: 'pushups-50',
      title: 'Power Training',
      type: QuestType.strength,
      icon: Icons.fitness_center,
      description: 'Complete 50 pushups in 3 minutes',
      targetDuration: Duration(minutes: 3),
      xpReward: 150,
    ),
  ];

  final List<Quest> _completedQuests = [];

  @override
  Future<List<Quest>> getAvailableQuests() async {
    return _allQuests.where((quest) => 
      !_completedQuests.any((c) => c.id == quest.id)).toList();
  }

  @override
  Future<void> saveCompletedQuest(Quest quest) async {
    _completedQuests.add(quest);
  }

  @override
  Future<List<Quest>> getCompletedQuests() async {
    return _completedQuests;
  }
}