import 'package:connect_b/features/directory/domain/entities/alumni_profile.dart';

abstract class DirectoryRepository {
  Future<List<AlumniProfile>> fetchAlumni({
    String query,
    String? batch,
    String? company,
    String? country,
    int limit,
  });
  Future<DirectoryFilterOptions> getFilterOptions();
}
