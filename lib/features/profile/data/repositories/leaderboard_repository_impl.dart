//lib/features/profile/data/repositories/leaderboard_repository_impl.dart
/// Leaderboard Repository Implementation
/// 
/// Concrete implementation of [LeaderboardRepository] that handles data operations
/// for leaderboard entries using the local database. Uses Floor ORM for database interactions
/// and follows the repository pattern to abstract data source details from the domain layer.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';
import 'package:solo_leveling/global_data/models/user.dart';

/// Implementation of [LeaderboardRepository] for local database operations
/// 
/// Annotated with [@Injectable] to enable dependency injection, registered as the
/// concrete type for [LeaderboardRepository]. Uses [AppDatabase] to access user and
/// quest history data for generating leaderboard rankings.
@Injectable(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  /// Local database instance for data operations
  final AppDatabase _database;

  /// Constructor: Initializes with a database instance (injected via DI)
  /// 
  /// [_database]: Instance of [AppDatabase] for accessing DAOs and raw queries
  LeaderboardRepositoryImpl(this._database);

  /// Retrieves top users based on ranking type and limit from local database
  /// 
  /// Implements the core logic for fetching and sorting users by XP:
  /// - All-time: Sorts by total XP across all time
  /// - Weekly: Sorts by XP earned in the last 7 days
  /// - Monthly: Sorts by XP earned in the last 30 days
  /// 
  /// [type]: The ranking period (all-time, weekly, monthly) from [RankingType]
  /// [limit]: Maximum number of entries to return (e.g., top 10)
  /// 
  /// Returns: 
  /// - [Right]: List of [LeaderboardEntry] sorted by rank on success
  /// - [Left]: [CacheFailure] with error message if database operations fail
  /// 
  /// Note for collaborators:
  /// - Raw SQL queries are used for time-based filters (weekly/monthly) to efficiently
  ///   join User and QuestHistory tables. Modify these queries carefully to avoid breaking
  ///   date filtering logic.
  /// - The `INTEGER` column references in queries appear to be placeholders - replace with
  ///   actual column names (e.g., `timestamp` for QuestHistory) when schema is finalized.
  /// - Rank is calculated dynamically using the result index + 1. This works for small
  ///   limits but consider adding a window function for large datasets.
  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getTopUsers(
    RankingType type,
    int limit,
  ) async {
    try {
      // Get raw database access for complex queries
      final db = _database.database;
      late List<Map<String, Object?>> results;

      // Select and sort users based on the ranking type
      switch (type) {
        case RankingType.allTime:
          // All-time ranking: Sort by total XP descending
          results = await db.query(
            'User',
            columns: ['id', 'username', 'totalXp', 'INTEGER'], // 'INTEGER'is actually the name for 'lastActive' time column
            orderBy: 'totalXp DESC',
            limit: limit,
          );
          break;

        case RankingType.weekly:
          // Weekly ranking: Sum XP from quests in the last 7 days
          final weekAgo = DateTime.now().subtract(const Duration(days: 7));
          results = await db.rawQuery('''
            SELECT u.id, u.username, u.totalXp, u.INTEGER
            FROM User u
            JOIN QuestHistory qh ON u.id = qh.userId
            WHERE qh.INTEGER >= ? // TODO: Replace 'INTEGER' with 'timestamp'
            GROUP BY u.id
            ORDER BY SUM(qh.xpEarned) DESC
            LIMIT ?
          ''', [weekAgo.millisecondsSinceEpoch, limit]);
          break;

        case RankingType.monthly:
          // Monthly ranking: Sum XP from quests in the last 30 days
          final monthAgo = DateTime.now().subtract(const Duration(days: 30));
          results = await db.rawQuery('''
            SELECT u.id, u.username, u.totalXp, u.INTEGER
            FROM User u
            JOIN QuestHistory qh ON u.id = qh.userId
            WHERE qh.INTEGER >= ? // TODO: Replace 'INTEGER' with 'timestamp'
            GROUP BY u.id
            ORDER BY SUM(qh.xpEarned) DESC
            LIMIT ?
          ''', [monthAgo.millisecondsSinceEpoch, limit]);
          break;
      }

      // Map database results to domain entities (LeaderboardEntry)
      final entries = results.map((map) {
        final user = User.fromJson(map);
        return LeaderboardEntry(
          rank: results.indexOf(map) + 1, // Calculate rank from result position
          userId: user.username,
          score: user.totalXp,
          isCurrentUser: false, // TODO: Add logic to check if user is current logged-in user
          rankingType: type,
          updatedAt: user.lastActive,
        );
      }).toList();

      return Right(entries);
    } catch (e) {
      // Catch and wrap all database errors in a CacheFailure
      return Left(CacheFailure(message: 'Error fetching leaderboard: $e'));
    }
  }
}
