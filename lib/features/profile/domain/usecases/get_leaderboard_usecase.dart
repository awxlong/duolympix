// lib/features/profile/domain/usecases/get_leaderboard_usecase.dart
/// Get Leaderboard Use Case
/// 
/// Encapsulates the business logic for retrieving leaderboard data.
/// Follows the use case pattern to separate the leaderboard retrieval logic
/// from the presentation layer, ensuring a clean architecture and easier testing.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';

/// Use case for fetching leaderboard entries
/// 
/// Annotated with [@injectable] to enable dependency injection.
/// Delegates the actual data retrieval to [LeaderboardRepository], abstracting
/// the data source details (e.g., API, database) from the caller.
@injectable
class GetLeaderboardUseCase {
  /// Repository dependency for leaderboard operations
  final LeaderboardRepository _repository;

  /// Constructor with injected repository
  GetLeaderboardUseCase(this._repository);

  /// Executes the use case to retrieve leaderboard entries
  /// 
  /// [type]: The ranking type (e.g., all-time, weekly)
  /// [limit]: The maximum number of entries to retrieve
  /// 
  /// Returns:
  /// - [Right<List<LeaderboardEntry>>] containing leaderboard entries on success
  /// - [Left<Failure>] describing the error if retrieval fails (e.g., network issue)
  /// 
  /// Future extensions:
  /// - Add pagination support (offset parameter)
  /// - Implement caching strategies for frequent requests
  /// - Add filtering by categories (e.g., running, strength)
  /// - Implement user-specific ranking retrieval
  Future<Either<Failure, List<LeaderboardEntry>>> call(
    RankingType type,
    int limit,
  ) {
    return _repository.getTopUsers(type, limit);
  }
}