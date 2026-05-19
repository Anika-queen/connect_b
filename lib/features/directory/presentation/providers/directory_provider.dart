import 'package:connect_b/features/directory/data/repositories/directory_repository_impl.dart';
import 'package:connect_b/features/directory/domain/entities/alumni_profile.dart';
import 'package:connect_b/features/directory/domain/repositories/directory_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

final directoryRepositoryProvider = Provider<DirectoryRepository>((ref) {
  return DirectoryRepositoryImpl(ref.read(supabaseClientProvider));
});

class DirectoryState {
  const DirectoryState({
    this.alumni = const [],
    this.options,
    this.loading = false,
    this.error,
  });

  final List<AlumniProfile> alumni;
  final DirectoryFilterOptions? options;
  final bool loading;
  final String? error;

  DirectoryState copyWith({
    List<AlumniProfile>? alumni,
    DirectoryFilterOptions? options,
    bool? loading,
    String? error,
  }) {
    return DirectoryState(
      alumni: alumni ?? this.alumni,
      options: options ?? this.options,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class DirectoryNotifier extends StateNotifier<DirectoryState> {
  DirectoryNotifier(this._repo) : super(const DirectoryState()) {
    load();
  }

  final DirectoryRepository _repo;
  String _query = '';
  String? _batch;
  String? _company;
  String? _country;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _repo.fetchAlumni(
          query: _query,
          batch: _batch,
          company: _company,
          country: _country,
        ),
        _repo.getFilterOptions(),
      ]);
      state = DirectoryState(
        alumni: results[0] as List<AlumniProfile>,
        options: results[1] as DirectoryFilterOptions,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load directory.',
      );
    }
  }

  void setBatch(String? value) {
    _batch = value;
    load();
  }

  void setCompany(String? value) {
    _company = value;
    load();
  }

  void setCountry(String? value) {
    _country = value;
    load();
  }

  void clearFilters() {
    _batch = null;
    _company = null;
    _country = null;
    load();
  }
}

final directoryProvider =
    StateNotifierProvider<DirectoryNotifier, DirectoryState>((ref) {
  return DirectoryNotifier(ref.read(directoryRepositoryProvider));
});
