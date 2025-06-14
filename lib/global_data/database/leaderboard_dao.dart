// lib/global_data/database/leaderboard_dao.dart
import 'package:floor/floor.dart';
import 'package:solo_leveling/global_data/models/enums.dart';

import '../models/leaderboard_entry.dart';

@dao
abstract class LeaderboardDao {
  @Query('SELECT * FROM LeaderboardEntry WHERE rankingType = :type ORDER BY rank ASC LIMIT :limit')
  Future<List<LeaderboardEntry>> getTopEntries(RankingType type, int limit);

  @Query('SELECT * FROM LeaderboardEntry WHERE userId = :userId AND rankingType = :type')
  Future<LeaderboardEntry?> getUserEntry(int userId, RankingType type);

  @insert
  Future<void> insertEntry(LeaderboardEntry entry);

  @update
  Future<void> updateEntry(LeaderboardEntry entry);
}
