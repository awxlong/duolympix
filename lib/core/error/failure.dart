// lib/core/error/failure.dart
abstract class Failure {
  final String message;

  const Failure({required this.message});
}

// Generic cache failure
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to retrieve data from cache'});
}

// Generic server failure
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

// Network connection failure
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

// Input validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Input validation failed'});
}
