class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.details,
    this.eventLocation,
    this.eventDate,
    this.createdAt,
  });

  final int id;
  final String title;
  final String details;
  final String? eventLocation;
  final DateTime? eventDate;
  final DateTime? createdAt;

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: (map['id'] as num).toInt(),
      title: (map['title'] ?? '').toString(),
      details: (map['details'] ?? '').toString(),
      eventLocation: map['event_location']?.toString(),
      eventDate: _parseDate(map['event_date']),
      createdAt: _parseDate(map['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
