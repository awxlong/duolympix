// lib/features/profile/domain/usecases/complete_quest_usecase.dart
/// Complete Quest Use Case
/// 
/// Encapsulates the business logic for marking a quest as completed by a user.
/// Follows the use case pattern to separate quest completion logic from the presentation layer,
/// ensuring consistent handling of user progress updates.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';

/// Use case for processing quest completion
/// 
/// Annotated with [@injectable] to enable dependency injection.
/// Delegates the actual completion logic to [UserRepository], abstracting
/// data source details and ensuring business rules are enforced.
@injectable
class CompleteQuestUseCase {
  /// Repository dependency for user and quest operations
  final UserRepository _repository;

  /// Constructor with injected repository
  CompleteQuestUseCase(this._repository);

  /// Executes the use case to mark a quest as completed
  /// 
  /// [quest]: The quest being completed
  /// [username]: The username of the user completing the quest
  /// 
  /// Returns:
  /// - [Right<void>] on successful completion
  /// - [Left<Failure>] describing the error if completion fails (e.g., invalid quest)
  Future<Either<Failure, void>> call(Quest quest, String username) {
    return _repository.completeQuest(quest, username);
  }
}
