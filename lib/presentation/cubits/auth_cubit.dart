import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  AuthCubit(this._repository) : super(AuthInitial()) {
    _subscription = _repository.authStateChanges.listen((user) {
      emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated());
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repository.signIn(email: email, password: password);
      // authStateChanges listener above will emit AuthAuthenticated.
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      await _repository.signUp(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signOut() => _repository.signOut();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
