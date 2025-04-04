import '../models/quest_model.dart';

abstract class QuestRepository {
  Future<List<Quest>> getAvailableQuests();
  Future<void> saveCompletedQuest(Quest quest);
  Future<List<Quest>> getCompletedQuests();
}