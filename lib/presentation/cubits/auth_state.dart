import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Auth status not yet known (waiting for the first authStateChanges event).
class AuthInitial extends AuthState {}

/// A sign-in/sign-up request is in flight.
class AuthLoading extends AuthState {}

/// User is signed in.
class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.uid];
}

/// User is signed out.
class AuthUnauthenticated extends AuthState {}

/// Sign-in/sign-up failed. Holds the previous "unauthenticated" screen open
/// and shows [message] (e.g. as a SnackBar).
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
