import 'package:connect_b/features/jobs/domain/entities/job_post.dart';
import 'package:connect_b/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// lisa updates 
class JobsRepositoryImpl implements JobsRepository {
  JobsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<JobPost>> fetchJobs({int limit = 40}) async {
    final response = await _client
        .from('jobs')
        .select(
          'id, title, company, location, deadline, application_url, created_at',
        )
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((r) => JobPost.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Set<int>> fetchSavedJobIds(String userId) async {
    final response = await _client
        .from('saved_jobs')
        .select('job_id')
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((r) => (r as Map<String, dynamic>)['job_id'] as num)
        .map((id) => id.toInt())
        .toSet();
  }

  @override
  Future<void> saveJob(String userId, int jobId) async {
    await _client.from('saved_jobs').upsert({
      'user_id': userId,
      'job_id': jobId,
    });
  }

  @override
  Future<void> unsaveJob(String userId, int jobId) async {
    await _client
        .from('saved_jobs')
        .delete()
        .eq('user_id', userId)
        .eq('job_id', jobId);
  }

  @override
  Future<void> createJob({
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
    required String postedBy,
  }) async {
    await _client.from('jobs').insert({
      'title': title.trim(),
      'company': company.trim(),
      if (location?.trim().isNotEmpty == true) 'location': location!.trim(),
      if (deadline != null)
        'deadline': deadline.toIso8601String().split('T').first,
      if (applicationUrl?.trim().isNotEmpty == true)
        'application_url': applicationUrl!.trim(),
      'posted_by': postedBy,
    });
  }

  @override
  Future<void> updateJob({
    required int id,
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
  }) async {
    await _client.from('jobs').update({
      'title': title.trim(),
      'company': company.trim(),
      if (location?.trim().isNotEmpty == true) 'location': location!.trim(),
      if (deadline != null)
        'deadline': deadline.toIso8601String().split('T').first,
      if (applicationUrl?.trim().isNotEmpty == true)
        'application_url': applicationUrl!.trim(),
    }).eq('id', id);
  }

  @override
  Future<void> deleteJob(int id) async {
    await _client.from('jobs').delete().eq('id', id);
  }
}
