import 'package:connect_b/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:connect_b/features/jobs/domain/entities/job_post.dart';
import 'package:connect_b/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepositoryImpl(ref.read(supabaseClientProvider));
});

class JobsState {
  const JobsState({
    this.jobs = const [],
    this.savedIds = const {},
    this.loading = false,
    this.error,
  });

  final List<JobPost> jobs;
  final Set<int> savedIds;
  final bool loading;
  final String? error;

  JobsState copyWith({
    List<JobPost>? jobs,
    Set<int>? savedIds,
    bool? loading,
    String? error,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      savedIds: savedIds ?? this.savedIds,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class JobsNotifier extends StateNotifier<JobsState> {
  JobsNotifier(this._repo) : super(const JobsState());

  final JobsRepository _repo;
  String? _userId;

  void init(String userId) {
    _userId = userId;
    load();
  }

  Future<void> load() async {
    if (_userId == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.fetchJobs(),
        _repo.fetchSavedJobIds(_userId!),
      ]);
      state = JobsState(
        jobs: results[0] as List<JobPost>,
        savedIds: results[1] as Set<int>,
      );
    } catch (_) {
      state = state.copyWith(loading: false, error: 'Could not load jobs.');
    }
  }

  Future<void> toggleSave(int jobId) async {
    if (_userId == null) return;
    final isSaved = state.savedIds.contains(jobId);
    // Optimistic update
    final newIds = {...state.savedIds};
    if (isSaved) {
      newIds.remove(jobId);
    } else {
      newIds.add(jobId);
    }
    state = state.copyWith(savedIds: newIds);

    try {
      if (isSaved) {
        await _repo.unsaveJob(_userId!, jobId);
      } else {
        await _repo.saveJob(_userId!, jobId);
      }
    } catch (_) {
      // Rollback
      state = state.copyWith(savedIds: state.savedIds);
    }
  }

  Future<bool> create({
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
  }) async {
    if (_userId == null) return false;
    try {
      await _repo.createJob(
        title: title,
        company: company,
        location: location,
        deadline: deadline,
        applicationUrl: applicationUrl,
        postedBy: _userId!,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update({
    required int id,
    required String title,
    required String company,
    String? location,
    DateTime? deadline,
    String? applicationUrl,
  }) async {
    try {
      await _repo.updateJob(
        id: id,
        title: title,
        company: company,
        location: location,
        deadline: deadline,
        applicationUrl: applicationUrl,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.deleteJob(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final jobsProvider = StateNotifierProvider.autoDispose<JobsNotifier, JobsState>(
  (ref) => JobsNotifier(ref.read(jobsRepositoryProvider)),
);
