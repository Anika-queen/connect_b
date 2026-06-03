class AlumniProfile {
  const AlumniProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
    this.batch,
    this.company,
    this.country,
    this.expertise,
    this.avatarUrl,
  });
// lisa updates this
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? department;
  final String? batch;
  final String? company;
  final String? country;
  final String? expertise;
  final String? avatarUrl;

  String get subtitle {
    final parts = <String>[
      if (department != null && department!.trim().isNotEmpty) department!,
      if (batch != null && batch!.trim().isNotEmpty) 'Batch $batch',
      if (company != null && company!.trim().isNotEmpty) company!,
      if (country != null && country!.trim().isNotEmpty) country!,
    ];
    return parts.isEmpty ? email : parts.join(' • ');
  }

  factory AlumniProfile.fromMap(Map<String, dynamic> map) {
    return AlumniProfile(
      id: map['id'] as String,
      fullName: (map['full_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
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

class DirectoryFilterOptions {
  const DirectoryFilterOptions({
    required this.batches,
    required this.companies,
    required this.countries,
  });

  final List<String> batches;
  final List<String> companies;
  final List<String> countries;
}
