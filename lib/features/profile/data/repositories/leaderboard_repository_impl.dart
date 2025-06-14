import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';
import 'package:solo_leveling/global_data/models/user.dart';

@Injectable(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final AppDatabase _database;

  LeaderboardRepositoryImpl(this._database);

  @override
Future<Either<Failure, List<LeaderboardEntry>>> getTopUsers(
  RankingType type,
  int limit,
) async {
  try {
    final db = _database.database;
    late List<Map<String, Object?>> results;

    // Select top users based on ranking type
    switch (type) {
      case RankingType.allTime:
        results = await db.query(
          'User',
          columns: ['id', 'username', 'totalXp', 'INTEGER'],
          orderBy: 'totalXp DESC',
          limit: limit,
        );
        break;

      case RankingType.weekly:
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        results = await db.rawQuery('''
          SELECT u.id, u.username, u.totalXp, u.INTEGER
          FROM User u
          JOIN QuestHistory qh ON u.id = qh.userId
          WHERE qh.INTEGER >= ?
          GROUP BY u.id
          ORDER BY SUM(qh.xpEarned) DESC
          LIMIT ?
        ''', [weekAgo.millisecondsSinceEpoch, limit]);
        break;

      case RankingType.monthly:
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        results = await db.rawQuery('''
          SELECT u.id, u.username, u.totalXp, u.INTEGER
          FROM User u
          JOIN QuestHistory qh ON u.id = qh.userId
          WHERE qh.INTEGER >= ?
          GROUP BY u.id
          ORDER BY SUM(qh.xpEarned) DESC
          LIMIT ?
        ''', [monthAgo.millisecondsSinceEpoch, limit]);
        break;
    }

    // Map database results to domain entities
    final entries = results.map((map) {
      final user = User.fromJson(map);
      return LeaderboardEntry(
        rank: results.indexOf(map) + 1,
        userId: user.username,
        score: user.totalXp,
        isCurrentUser: false,
        rankingType: type,
        updatedAt: user.lastActive,
      );
    }).toList();

    return Right(entries);
  } catch (e) {
    return Left(CacheFailure(message: 'Error fetching leaderboard: $e'));
  }
}

}
