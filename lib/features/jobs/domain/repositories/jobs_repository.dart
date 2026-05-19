import 'package:connect_b/features/jobs/domain/entities/job_post.dart';

abstract class JobsRepository {
  Future<List<JobPost>> fetchJobs({int limit});
  Future<Set<int>> fetchSavedJobIds(String userId);
  Future<void> saveJob(String userId, int jobId);
  Future<void> unsaveJob(String userId, int jobId);
  Future<void> createJob({
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
    required String postedBy,
  });
  Future<void> updateJob({
    required int id,
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
  });
  Future<void> deleteJob(int id);
}
