import '../entities/app_user.dart';

abstract class IAuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();
}
