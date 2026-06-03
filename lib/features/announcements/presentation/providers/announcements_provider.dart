import 'package:connect_b/features/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:connect_b/features/announcements/domain/entities/announcement.dart';
import 'package:connect_b/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

final announcementsRepositoryProvider =
    Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepositoryImpl(ref.read(supabaseClientProvider));
});
//nipa : update this
class AnnouncementsState {
  const AnnouncementsState({
    this.announcements = const [],
    this.loading = false,
    this.error,
  });

  final List<Announcement> announcements;
  final bool loading;
  final String? error;

  AnnouncementsState copyWith({
    List<Announcement>? announcements,
    bool? loading,
    String? error,
  }) {
    return AnnouncementsState(
      announcements: announcements ?? this.announcements,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AnnouncementsNotifier extends StateNotifier<AnnouncementsState> {
  AnnouncementsNotifier(this._repo) : super(const AnnouncementsState()) {
    load();
  }

  final AnnouncementsRepository _repo;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repo.fetchAll();
      state = AnnouncementsState(announcements: data);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load announcements.',
      );
    }
  }

  Future<bool> create({
    required String title,
    required String details,
    String? eventLocation,
    DateTime? eventDate,
    required String createdBy,
  }) async {
    try {
      await _repo.create(
        title: title,
        details: details,
        eventLocation: eventLocation,
        eventDate: eventDate,
        createdBy: createdBy,
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
    required String details,
    String? eventLocation,
    DateTime? eventDate,
  }) async {
    try {
      await _repo.update(
        id: id,
        title: title,
        details: details,
        eventLocation: eventLocation,
        eventDate: eventDate,
      );
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _repo.delete(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final announcementsProvider =
    StateNotifierProvider.autoDispose<AnnouncementsNotifier, AnnouncementsState>(
  (ref) => AnnouncementsNotifier(ref.read(announcementsRepositoryProvider)),
);
