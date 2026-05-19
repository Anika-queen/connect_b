class JobPost {
  const JobPost({
    required this.id,
    required this.title,
    required this.company,
    this.location,
    this.deadline,
    this.applicationUrl,
    this.createdAt,
  });

  final int id;
  final String title;
  final String company;
  final String? location;
  final DateTime? deadline;
  final String? applicationUrl;
  final DateTime? createdAt;

  factory JobPost.fromMap(Map<String, dynamic> map) {
    return JobPost(
      id: (map['id'] as num).toInt(),
      title: (map['title'] ?? '').toString(),
      company: (map['company'] ?? '').toString(),
      location: map['location']?.toString(),
      deadline: _parseDate(map['deadline']),
      applicationUrl: map['application_url']?.toString(),
      createdAt: _parseDate(map['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
