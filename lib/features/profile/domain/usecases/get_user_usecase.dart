// lib/features/profile/domain/usecases/get_user_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../data/repositories/user_repository.dart';
import '../entities/user_entity.dart';

@injectable
class GetUserUseCase {
  final UserRepository _repository;

  GetUserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(String email) {
    return _repository.getUser(email);
  }
}
