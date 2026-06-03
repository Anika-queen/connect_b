import 'package:connect_b/features/auth/domain/entities/user.dart';
import 'package:connect_b/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;
// shanu : update this page
  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Sign in failed');

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return AppUser.fromMap({
      ...profile,
      'id': user.id,
      'email': user.email ?? email,
    });
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String department,
    required String batch,
  }) async {
    await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'role': role.toLowerCase(),
        'department': department.trim(),
        'batch': batch.trim(),
      },
    );
    return AppUser(
      id: '',
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
      role: role.toLowerCase(),
      department: department.trim(),
      batch: batch.trim(),
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<AppUser?> currentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();
    if (profile == null) return null;

    return AppUser.fromMap({
      ...profile,
      'id': authUser.id,
      'email': authUser.email ?? '',
    });
  }

  @override
  Future<void> resendVerification(String email) async {
    await _client.auth.resend(
      email: email.trim().toLowerCase(),
      type: OtpType.signup,
    );
  }
}
