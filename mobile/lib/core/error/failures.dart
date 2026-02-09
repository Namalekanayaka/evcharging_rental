abstract class Failure implements Exception {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) : super(message: message);
}

class ValidationFailure extends Failure {
  ValidationFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  NetworkFailure({required String message}) : super(message: message);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({required String message}) : super(message: message);
}

class ApiFailure extends Failure {
  ApiFailure({required String message}) : super(message: message);
}
