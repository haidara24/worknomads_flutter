part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  LoginRequested({required this.username, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String password;
  RegisterRequested({required this.username, required this.password});
}

class LogoutRequested extends AuthEvent {}
