// lib/features/profile/domain/repositories/user_repository.dart (Abstract)
import 'package:dartz/dartz.dart';
import '../../../../features/profile/domain/entities/user_entity.dart';
import '../../../quests/data/models/quest_model.dart';
import '../../../../core/error/failure.dart';

abstract class UserRepository {
  UserRepository(database);

  Future<Either<Failure, UserEntity>> getUser(String email);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);
  Future<Either<Failure, void>> completeQuest(Quest quest, String username);
  Future<Either<Failure, void>> updateLeaderboard();
}