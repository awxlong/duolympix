// lib/features/profile/domain/repositories/leaderboard_repository.dart
/// Leaderboard Repository Interface
/// 
/// Defines the contract for retrieving leaderboard data, following the repository pattern.
/// Acts as an abstraction between the domain layer and data layer, isolating business logic
/// from data source implementation details (e.g., local database, API).
library;
import 'package:dartz/dartz.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';

/// Abstract base class for leaderboard data operations
/// 
/// Declares the primary method for fetching top users based on ranking criteria.
/// Uses Either from the dartz package to handle success/failure cases explicitly,
/// ensuring errors are propagated properly without throwing exceptions.
abstract class LeaderboardRepository {
  /// Retrieves top users based on ranking type and limit
  /// 
  /// [type]: The ranking category (e.g., all-time, weekly, monthly) from [RankingType] enum
  /// [limit]: Maximum number of entries to return (e.g., top 10 users)
  /// 
  /// Returns: A [Future] containing [Either]:
  /// - [Right]: List of [LeaderboardEntry] objects on success
  /// - [Left]: [Failure] instance describing the error on failure
  Future<Either<Failure, List<LeaderboardEntry>>> getTopUsers(
    RankingType type,
    int limit,
  );
}
