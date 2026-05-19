import 'package:connect_b/features/auth/domain/entities/user.dart';
import 'package:connect_b/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return AppUser.fromMap({...data, 'id': userId});
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String department,
    required String batch,
    String? company,
    String? country,
    String? expertise,
  }) async {
    await _client.from('profiles').update({
      'full_name': fullName.trim(),
      'department': department.trim(),
      'batch': batch.trim(),
      if (company?.trim().isNotEmpty == true) 'company': company!.trim(),
      if (country?.trim().isNotEmpty == true) 'country': country!.trim(),
      if (expertise?.trim().isNotEmpty == true) 'expertise': expertise!.trim(),
    }).eq('id', userId);
  }
}
