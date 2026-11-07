class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int orderCount;
  final int favoriteCount;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.orderCount = 0,
    this.favoriteCount = 0,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? orderCount,
    int? favoriteCount,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      orderCount: orderCount ?? this.orderCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
  );
}
