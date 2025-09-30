import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worknomads_flutter/core/utils/jwt_utils.dart';
import 'package:worknomads_flutter/features/auth/data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await authRepository.getAccessToken();
        if (token != null && !JwtUtils.isTokenExpired(token)) {
          final payload = JwtUtils.decodePayload(token);
          final username = payload['sub'] ?? payload['username'] ?? 'user';
          emit(AuthAuthenticated(username: username));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final tokenPair = await authRepository.login(
          event.username,
          event.password,
        );
        final username =
            JwtUtils.decodePayload(tokenPair.access)['sub'] ?? event.username;
        emit(AuthAuthenticated(username: username));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AuthUnauthenticated());
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.register(event.username, event.password);
        // after successful register, auto-login
        final tokenPair = await authRepository.login(
          event.username,
          event.password,
        );
        final username =
            JwtUtils.decodePayload(tokenPair.access)['sub'] ?? event.username;
        emit(AuthAuthenticated(username: username));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
        await Future.delayed(const Duration(milliseconds: 500));
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}
