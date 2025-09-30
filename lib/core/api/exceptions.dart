/// app-level exceptions for easier mapping and tests
class AppException implements Exception {
  final String message;
  AppException([this.message = 'An error occurred']);
  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException([String msg = 'Network error']) : super(msg);
}

class AuthException extends AppException {
  AuthException([String msg = 'Authentication error']) : super(msg);
}

class ServerException extends AppException {
  ServerException([String msg = 'Server error']) : super(msg);
}
