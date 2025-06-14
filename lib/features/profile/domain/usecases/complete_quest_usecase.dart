// lib/features/profile/domain/usecases/complete_quest_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../data/repositories/user_repository.dart';
import '../../../quests/data/models/quest_model.dart';

@injectable
class CompleteQuestUseCase {
  final UserRepository _repository;

  CompleteQuestUseCase(this._repository);

  Future<Either<Failure, void>> call(Quest quest) {
    return _repository.completeQuest(quest);
  }
}
