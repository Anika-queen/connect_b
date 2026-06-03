class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.department,
    this.batch,
    this.company,
    this.country,
    this.expertise,
    this.avatarUrl,
  });
// lisa updates
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? department;
  final String? batch;
  final String? company;
  final String? country;
  final String? expertise;
  final String? avatarUrl;

  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? fullName,
    String? department,
    String? batch,
    String? company,
    String? country,
    String? expertise,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role,
      department: department ?? this.department,
      batch: batch ?? this.batch,
      company: company ?? this.company,
      country: country ?? this.country,
      expertise: expertise ?? this.expertise,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: (map['email'] ?? '').toString(),
      fullName: (map['full_name'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      department: map['department']?.toString(),
      batch: map['batch']?.toString(),
      company: map['company']?.toString(),
      country: map['country']?.toString(),
      expertise: map['expertise']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
    );
  }
}
