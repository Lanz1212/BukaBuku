class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int orderCount;
  final int favoriteCount;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.orderCount = 0,
    this.favoriteCount = 0,
    this.avatarUrl,
    this.role = 'user',
    this.createdAt,
  });

  /// Format tanggal bergabung dengan kalender lokal Indonesia (contoh: "Oktober 2026")
  String get joinedDateFormatted {
    if (createdAt == null) return '-';
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final local = createdAt!.toLocal();
    return '${months[local.month - 1]} ${local.year}';
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? orderCount,
    int? favoriteCount,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      orderCount: orderCount ?? this.orderCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserProfile.fromSupabase(
    Map<String, dynamic> data, {
    int orderCount = 0,
    int favoriteCount = 0,
  }) {
    final fullName = (data['full_name'] as String?)?.trim() ?? '';
    final email = (data['email'] as String?)?.trim() ?? '';
    final phone = (data['phone'] as String?)?.trim() ?? '';
    final avatarUrl = (data['avatar_url'] as String?)?.trim();
    final role = (data['role'] as String?)?.trim() ?? 'user';
    final createdAtStr = data['created_at'] as String?;
    final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

    return UserProfile(
      id: data['id']?.toString() ?? '',
      name: fullName.isNotEmpty
          ? fullName
          : (email.isNotEmpty ? email.split('@').first : 'Pengguna Buka Buku'),
      email: email,
      phone: phone,
      orderCount: orderCount,
      favoriteCount: favoriteCount,
      avatarUrl: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null,
      role: role,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'full_name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static const defaultProfile = UserProfile(
    id: '',
    name: 'Pengguna',
    email: '',
    phone: '',
    orderCount: 0,
    favoriteCount: 0,
    avatarUrl: null,
    role: 'user',
    createdAt: null,
  );
}
