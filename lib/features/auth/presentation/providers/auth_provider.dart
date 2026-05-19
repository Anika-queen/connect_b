import 'package:connect_b/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:connect_b/features/auth/domain/entities/user.dart';
import 'package:connect_b/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(supabaseClientProvider));
});

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? error;

  AuthState copyWith({AuthStatus? status, AppUser? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _loadCurrentUser();
  }

  final AuthRepository _repo;

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _repo.currentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _repo.signIn(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return e.message;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Something went wrong.',
      );
      return 'Something went wrong.';
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String department,
    required String batch,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        department: department,
        batch: batch,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return null;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );
      return e.message;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Something went wrong.',
      );
      return 'Something went wrong.';
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<String?> resendVerification(String email) async {
    try {
      await _repo.resendVerification(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Unable to send email.';
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
