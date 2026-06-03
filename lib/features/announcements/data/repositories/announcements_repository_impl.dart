import 'package:connect_b/features/announcements/domain/entities/announcement.dart';
import 'package:connect_b/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// lisa: updates this

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Announcement>> fetchAll({int limit = 40}) async {
    final response = await _client
        .from('announcements')
        .select('id, title, details, event_location, event_date, created_at')
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .map((r) => Announcement.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> create({
    required String title,
    required String details,
    String? eventLocation,
    DateTime? eventDate,
    required String createdBy,
  }) async {
    await _client.from('announcements').insert({
      'title': title.trim(),
      'details': details.trim(),
      if (eventLocation?.trim().isNotEmpty == true)
        'event_location': eventLocation!.trim(),
      if (eventDate != null)
        'event_date': eventDate.toIso8601String().split('T').first,
      'created_by': createdBy,
    });
  }

  @override
  Future<void> update({
    required int id,
    required String title,
    required String details,
    String? eventLocation,
    DateTime? eventDate,
  }) async {
    await _client.from('announcements').update({
      'title': title.trim(),
      'details': details.trim(),
      if (eventLocation?.trim().isNotEmpty == true)
        'event_location': eventLocation!.trim(),
      if (eventDate != null)
        'event_date': eventDate.toIso8601String().split('T').first,
    }).eq('id', id);
  }

  @override
  Future<void> delete(int id) async {
    await _client.from('announcements').delete().eq('id', id);
  }
}
