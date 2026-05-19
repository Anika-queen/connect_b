import 'package:connect_b/features/auth/domain/entities/user.dart';

abstract class ProfileRepository {
  Future<AppUser> getProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String department,
    required String batch,
    String? company,
    String? country,
    String? expertise,
  });
}
