import 'package:connect_b/features/directory/domain/entities/alumni_profile.dart';
import 'package:connect_b/features/directory/domain/repositories/directory_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DirectoryRepositoryImpl implements DirectoryRepository {
  DirectoryRepositoryImpl(this._client);

  final SupabaseClient _client;
// shanu : update this page
  @override
  Future<List<AlumniProfile>> fetchAlumni({
    String query = '',
    String? batch,
    String? company,
    String? country,
    int limit = 80,
  }) async {
    var request = _client
        .from('profiles')
        .select(
          'id, full_name, email, role, department, batch, company, country, expertise, avatar_url',
        )
        .eq('role', 'alumni');

    final cleanedQuery = query.trim();
    if (cleanedQuery.isNotEmpty) {
      final safe = _sanitize(cleanedQuery);
      request = request.or(
        'full_name.ilike.*$safe*,department.ilike.*$safe*',
      );
    }
    if (batch != null && batch.trim().isNotEmpty) {
      request = request.eq('batch', batch.trim());
    }
    if (company != null && company.trim().isNotEmpty) {
      request = request.eq('company', company.trim());
    }
    if (country != null && country.trim().isNotEmpty) {
      request = request.eq('country', country.trim());
    }

    final response = await request.order('full_name').limit(limit);
    return (response as List<dynamic>)
        .map((r) => AlumniProfile.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DirectoryFilterOptions> getFilterOptions() async {
    final response = await _client
        .from('profiles')
        .select('batch, company, country')
        .eq('role', 'alumni')
        .limit(600);

    final batches = <String>{};
    final companies = <String>{};
    final countries = <String>{};

    for (final item in response as List<dynamic>) {
      final map = item as Map<String, dynamic>;
      final b = map['batch']?.toString().trim();
      final c = map['company']?.toString().trim();
      final co = map['country']?.toString().trim();
      if (b != null && b.isNotEmpty) batches.add(b);
      if (c != null && c.isNotEmpty) companies.add(c);
      if (co != null && co.isNotEmpty) countries.add(co);
    }

    return DirectoryFilterOptions(
      batches: batches.toList()..sort(),
      companies: companies.toList()..sort(),
      countries: countries.toList()..sort(),
    );
  }

  String _sanitize(String input) {
    return input
        .replaceAll(',', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('%', '')
        .replaceAll('*', '');
  }
}
