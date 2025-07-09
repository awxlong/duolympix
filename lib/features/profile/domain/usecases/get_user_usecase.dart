// lib/features/profile/domain/usecases/get_user_usecase.dart
/// Get User Use Case
/// 
/// Encapsulates the business logic for retrieving user data using credentials.
/// Follows the use case pattern to separate data retrieval logic from the presentation layer,
/// ensuring a clean architecture and easier testing.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:duolympix/core/error/failure.dart';
import 'package:duolympix/features/profile/data/repositories/user_repository.dart';
import 'package:duolympix/features/profile/domain/entities/user_entity.dart';

/// Use case for fetching a user by username and password
/// 
/// Annotated with [@injectable] to enable dependency injection.
/// Delegates the actual data retrieval to [UserRepository], abstracting
/// the data source details from the caller.
@injectable
class GetUserUseCase {
  /// Repository dependency for user data operations
  final UserRepository _repository;

  /// Constructor with injected repository
  GetUserUseCase(this._repository);

  /// Executes the use case to retrieve a user
  /// 
  /// [username]: The user's unique username
  /// [password]: The user's password for authentication
  /// 
  /// Returns:
  /// - [Right<UserEntity>] containing the user data on successful retrieval
  /// - [Left<Failure>] describing the error if retrieval fails (e.g., invalid credentials)
  Future<Either<Failure, UserEntity>> call(String username, password) {
    return _repository.getUser(username, password);
  }
}
