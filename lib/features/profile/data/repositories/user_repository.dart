// lib/features/profile/domain/repositories/user_repository.dart (Abstract)
/// User Repository Interface
/// 
/// Defines the contract for user-related data operations, following the repository pattern.
/// This interface abstracts the data source (e.g., local database, API) and provides
/// a clean API for domain layer use cases to interact with user data.
library;
import 'package:dartz/dartz.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/domain/entities/user_entity.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';

/// Abstract base class for user data operations
/// 
/// Declares methods for retrieving, updating users, and managing quest completions.
/// Uses the Either type from dartz to handle success/failure scenarios explicitly.
abstract class UserRepository {
  /// Constructor with database dependency
  /// 
  /// [database]: The database instance (type depends on implementation)
  /// Implementations should use this to initialize DAOs or data sources
  UserRepository(database);

  /// Retrieves a user by credentials
  /// 
  /// [username]: The user's unique username
  /// [password]: The user's password (should be hashed in storage)
  /// 
  /// Returns:
  /// - [Right<UserEntity>] on successful retrieval
  /// - [Left<Failure>] with appropriate error (e.g., AuthFailure, ServerFailure)
  Future<Either<Failure, UserEntity>> getUser(String username, String password);

  /// Updates user data in the repository
  /// 
  /// [user]: The updated user entity to persist
  /// 
  /// Returns:
  /// - [Right<UserEntity>] with the updated user on success
  /// - [Left<Failure>] if update fails (e.g., network error, validation failure)
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  /// Marks a quest as completed for a user
  /// 
  /// [quest]: The quest to complete
  /// [username]: The user completing the quest
  /// 
  /// Returns:
  /// - [Right<void>] on successful completion
  /// - [Left<Failure>] if completion fails (e.g., quest not found, user not found)
  Future<Either<Failure, void>> completeQuest(Quest quest, String username);

  /// Updates the user's position in the leaderboard
  /// 
  /// Should be called after significant XP changes (e.g., quest completion)
  /// 
  /// Returns:
  /// - [Right<void>] on successful update
  /// - [Left<Failure>] if update fails (e.g., leaderboard service unavailable)
  Future<Either<Failure, void>> updateLeaderboard();
}
