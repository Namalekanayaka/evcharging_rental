abstract class Failure implements Exception {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure(super.message);
}
