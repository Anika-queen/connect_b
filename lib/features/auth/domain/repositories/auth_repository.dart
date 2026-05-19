import 'package:connect_b/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({
    required String email,
    required String password,
  });
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String department,
    required String batch,
  });
  Future<void> signOut();
  Future<AppUser?> currentUser();
  Future<void> resendVerification(String email);
}
