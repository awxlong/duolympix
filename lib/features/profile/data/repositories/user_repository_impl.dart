//lib/features/profile/data/repositories/user_repository_impl.dart
/// User Repository Implementation
/// 
/// Concrete implementation of the [UserRepository] interface,
/// responsible for managing user data persistence using SQLite
/// database through Floor Object Relation Mapping. Handles user authentication,
/// profile updates, quest completions, and leaderboard management.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:duolympix/core/error/failure.dart';
import 'package:duolympix/features/profile/data/mappers/user_mapper.dart';
import 'package:duolympix/features/profile/data/repositories/user_repository.dart';
import 'package:duolympix/features/profile/domain/entities/user_entity.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';
import 'package:duolympix/global_data/database/app_database.dart';
import 'package:duolympix/global_data/models/quest_history.dart';
import 'package:duolympix/global_data/models/user.dart';
import 'package:sqflite/sqflite.dart';

/// Implementation of [UserRepository] using Floor database
/// 
/// Registers as a lazy singleton through dependency injection.
/// Maps between domain entities and database models,
/// and handles database operations for user-related data.
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  /// Database instance for data operations
  final AppDatabase _database;

  /// Constructor with injected database dependency
  UserRepositoryImpl(this._database);

  /// Retrieves a user by username and password
  /// 
  /// Returns:
  /// - [Right<UserEntity>] if user is found and password matches
  /// - [Left<DatabaseFailure>] if user not found or password is incorrect
  /// 
  /// Future extensions:
  /// - Implement password hashing (current implementation uses plain text)
  /// - Add user caching mechanism
  /// - Implement multi-factor authentication
  @override
  Future<Either<Failure, UserEntity>> getUser(String username, String password) async {
    try {
      final user = await _database.userDao.findUserByUsername(username);
      if (user == null) return const Left(DatabaseFailure(message: 'User not found'));
      if (user.password != password) return const Left(DatabaseFailure(message: 'Incorrect password'));
      return Right(UserMapper.mapUserToEntity(user));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Error fetching user: $e'));
    }
  }

  /// Updates user profile data
  /// 
  /// Converts [UserEntity] to database model, persists changes,
  /// and returns the updated entity.
  /// 
  /// Returns:
  /// - [Right<UserEntity>] on successful update
  /// - [Left<CacheFailure>] on database error
  /// 
  /// Future extensions:
  /// - Add validation before updating
  /// - Implement optimistic updates with conflict resolution
  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    try {
      final dbUser = UserMapper.mapEntityToUser(user);
      await _database.userDao.updateUser(dbUser);
      return Right(user);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  /// Handles quest completion for a user
  /// 
  /// Updates user's XP, level, quest count, and streak.
  /// Logs quest completion in history and updates leaderboard.
  /// 
  /// Returns:
  /// - [Right<void>] on successful completion
  /// - [Left<CacheFailure>] on database error
  /// 
  /// Future extensions:
  /// - Implement achievement unlocks
  /// - Add streak bonuses
  /// - Implement daily quest limits
  @override
  Future<Either<Failure, void>> completeQuest(Quest quest, String username) async {
    try {
      // Get current user
      final user = await _database.userDao.findUserByUsername(username);
      if (user == null) return const Left(CacheFailure());

      // Update user's XP and stats
      final updatedUser = user.copyWith(
        totalXp: user.totalXp + quest.xpReward,
        level: _calculateLevel(user.totalXp + quest.xpReward),
        totalQuestsCompleted: user.totalQuestsCompleted + 1,
        lastActive: DateTime.now(),
        streak: _updateStreak(user.streak, user.lastActive),
      );

      // Save updated user
      await _database.userDao.updateUser(updatedUser);

      // Log quest completion
      final questHistory = QuestHistory(
        userId: updatedUser.id!,
        questId: quest.id,
        completionDate: DateTime.now(),
        xpEarned: quest.xpReward,
      );
      await _database.questHistoryDao.insertQuestHistory(questHistory);

      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  /// Updates the leaderboard based on user XP
  /// 
  /// Runs a database transaction to update rankings for all users.
  /// Orders users by total XP and assigns ranks accordingly.
  /// 
  /// Returns:
  /// - [Right<void>] on successful update
  /// - [Left<CacheFailure>] on database error
  /// 
  /// Future extensions:
  /// - Implement incremental leaderboard updates
  /// - Add support for different ranking categories
  /// - Optimize for large user bases
  @override
  Future<Either<Failure, void>> updateLeaderboard() async {
    try {
      // Get the actual Sqflite Database instance from Floor
      final db = _database.database.database;
      
      // Start transaction using the raw Database instance
      return await db.transaction((txn) async {
        // Get all users ordered by XP descending
        final users = await txn.query(
          'User',
          orderBy: 'totalXp DESC',
        );

        // Update leaderboard table with new rankings
        for (int i = 0; i < users.length; i++) {
          final user = User.fromJson(users[i]);
          
          // Insert or update user's ranking
          await txn.insert(
            'Leaderboard',
            {
              'userId': user.id,
              'rank': i + 1,
              'score': user.totalXp,
              'updatedAt': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        return const Right(null);
      });
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update leaderboard: $e'));
    }
  }

  /// Calculates user level based on total XP
  /// 
  /// Simple formula: Level = (XP / 100) + 1
  /// 
  /// Future extensions:
  /// - Implement non-linear leveling curve
  /// - Add support for skill-specific levels
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  /// Updates user's daily streak
  /// 
  /// Determines if streak should continue, reset, or stay the same
  /// based on the user's last activity date.
  /// 
  /// Future extensions:
  /// - Add streak bonuses
  /// - Implement streak decay over time
  int _updateStreak(int currentStreak, DateTime lastActive) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (lastActive.year == yesterday.year && 
        lastActive.month == yesterday.month && 
        lastActive.day == yesterday.day) {
      return currentStreak + 1; // Continue streak
    } else if (lastActive.year == now.year && 
               lastActive.month == now.month && 
               lastActive.day == now.day) {
      return currentStreak; // Same day, no change
    } else {
      return 1; // Reset streak
    }
  }
}
