// lib/global_data/database/quest_history_dao.dart
import 'package:floor/floor.dart';
import '../models/quest_history.dart';

@dao
abstract class QuestHistoryDao {
  @Query('SELECT * FROM QuestHistory WHERE userId = :userId ORDER BY completionDate DESC')
  Future<List<QuestHistory>> findAllByUserId(int userId);

  @Query('SELECT * FROM QuestHistory WHERE questId = :questId AND userId = :userId')
  Future<QuestHistory?> findByQuestIdAndUserId(String questId, int userId);

  @Query('SELECT COUNT(*) FROM QuestHistory WHERE userId = :userId')
  Future<int?> countByUserId(int userId);

  @Query('SELECT SUM(xpEarned) FROM QuestHistory WHERE userId = :userId')
  Future<int?> sumXpByUserId(int userId);

  @insert
  Future<void> insertQuestHistory(QuestHistory questHistory);

  @delete
  Future<void> deleteQuestHistory(QuestHistory questHistory);
}
