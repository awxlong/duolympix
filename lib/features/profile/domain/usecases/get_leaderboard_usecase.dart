// lib/features/profile/domain/usecases/get_leaderboard_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/global_data/models/enums.dart';
import 'package:solo_leveling/global_data/models/leaderboard_entry.dart';
import '../../../../core/error/failure.dart';


@injectable
class GetLeaderboardUseCase {
  final LeaderboardRepository _repository;

  GetLeaderboardUseCase(this._repository);

  Future<Either<Failure, List<LeaderboardEntry>>> call(
    RankingType type,
    int limit,
  ) {
    return _repository.getTopUsers(type, limit);
  }
}
