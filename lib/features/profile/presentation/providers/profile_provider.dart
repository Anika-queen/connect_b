import 'package:connect_b/features/auth/domain/entities/user.dart';
import 'package:connect_b/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:connect_b/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(supabaseClientProvider));
});
// lisa updates it
class ProfileNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  ProfileNotifier(this._repo) : super(const AsyncValue.data(null));

  final ProfileRepository _repo;

  Future<void> load(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.getProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> update({
    required String userId,
    required String fullName,
    required String department,
    required String batch,
    String? company,
    String? country,
    String? expertise,
  }) async {
    await _repo.updateProfile(
      userId: userId,
      fullName: fullName,
      department: department,
      batch: batch,
      company: company,
      country: country,
      expertise: expertise,
    );
    state = AsyncValue.data(
      AppUser(
        id: userId,
        email: state.value?.email ?? '',
        fullName: fullName,
        role: state.value?.role ?? '',
        department: department,
        batch: batch,
        company: company,
        country: country,
        expertise: expertise,
      ),
    );
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<AppUser?>>(
  (ref) => ProfileNotifier(ref.read(profileRepositoryProvider)),
);
