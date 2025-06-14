// lib/features/profile/domain/repositories/leaderboard_repository.dart
import 'package:dartz/dartz.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';


abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> getTopUsers(
    RankingType type,
    int limit,
  );
}
