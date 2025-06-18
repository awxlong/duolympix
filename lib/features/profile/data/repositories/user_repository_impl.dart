

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/data/mappers/user_mapper.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart';
import 'package:solo_leveling/features/profile/domain/entities/user_entity.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/global_data/models/quest_history.dart';
import 'package:solo_leveling/global_data/models/user.dart';
import 'package:sqflite/sqflite.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final AppDatabase _database;

  UserRepositoryImpl(this._database);

@override
Future<Either<Failure, UserEntity>> getUser(String username) async {
  try {
    final user = await _database.userDao.findUserByUsername(username);
    if (user == null) return const Left(DatabaseFailure(message: 'User not found'));
    return Right(UserMapper.mapUserToEntity(user));
  } catch (e) {
    return Left(DatabaseFailure(message: 'Error fetching user: $e'));
  }
}

@override
Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
  try {
    final dbUser = UserMapper.mapEntityToUser(user);
    await _database.userDao.updateUser(dbUser);
    // print('User data updated successfully: ${dbUser.username}');
    return Right(user);
  } catch (e) {
    return const Left(CacheFailure());
  }
}


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
      durationInSeconds: quest.targetDuration?.inSeconds,
    );
    await _database.questHistoryDao.insertQuestHistory(questHistory);

    return const Right(null);
  } catch (e) {
    return const Left(CacheFailure());
  }
}


  // Helper methods
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

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

}