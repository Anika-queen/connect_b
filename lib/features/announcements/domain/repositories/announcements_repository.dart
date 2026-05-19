import 'package:connect_b/features/announcements/domain/entities/announcement.dart';

abstract class AnnouncementsRepository {
  Future<List<Announcement>> fetchAll({int limit});
  Future<void> create({
    required String title,
    required String details,
    String? eventLocation,
    DateTime? eventDate,
    required String createdBy,
  });
  Future<void> update({
    required int id,
    required String title,
    required String details,
    String? eventLocation,
    DateTime? eventDate,
  });
  Future<void> delete(int id);
}
