class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? birthDate;
  final String? gender;
  final String membershipLevel;
  final int orderCount;
  final int favoriteCount;
  final int activeVouchers;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    this.gender,
    this.membershipLevel = 'Pembaca Terdaftar',
    this.orderCount = 4,
    this.favoriteCount = 4,
    this.activeVouchers = 1,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? membershipLevel,
    int? orderCount,
    int? favoriteCount,
    int? activeVouchers,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      orderCount: orderCount ?? this.orderCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      activeVouchers: activeVouchers ?? this.activeVouchers,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserProfile.fromSupabase(
    Map<String, dynamic> data, {
    int orderCount = 0,
    int favoriteCount = 4,
    int activeVouchers = 1,
  }) {
    final fullName = (data['full_name'] as String?)?.trim();
    final email = (data['email'] as String?)?.trim();
    final phone = (data['phone'] as String?)?.trim();
    final birthDate = (data['birth_date'] as String?)?.trim();
    final gender = (data['gender'] as String?)?.trim();
    final membershipLevel = (data['membership_level'] as String?)?.trim();
    final avatarUrl = (data['avatar_url'] as String?)?.trim();

    return UserProfile(
      id: data['id']?.toString() ?? 'user_001',
      name: (fullName != null && fullName.isNotEmpty)
          ? fullName
          : defaultProfile.name,
      email: (email != null && email.isNotEmpty)
          ? email
          : defaultProfile.email,
      phone: (phone != null && phone.isNotEmpty)
          ? phone
          : defaultProfile.phone,
      birthDate: (birthDate != null && birthDate.isNotEmpty)
          ? birthDate
          : defaultProfile.birthDate,
      gender: (gender != null && gender.isNotEmpty)
          ? gender
          : defaultProfile.gender,
      membershipLevel: (membershipLevel != null && membershipLevel.isNotEmpty)
          ? membershipLevel
          : 'Pembaca Terdaftar',
      orderCount: orderCount,
      favoriteCount: favoriteCount,
      activeVouchers: activeVouchers,
      avatarUrl: (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : defaultProfile.avatarUrl,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'full_name': name,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'avatar_url': avatarUrl,
      'membership_level': membershipLevel,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static const defaultProfile = UserProfile(
    id: 'user_001',
    name: 'Budi Santoso',
    email: 'budi.santoso@email.com',
    phone: '+62 812-3456-7890',
    birthDate: '15 Agustus 1990',
    gender: 'Laki-laki',
    membershipLevel: 'Pembaca Terdaftar',
    orderCount: 4,
    favoriteCount: 4,
    activeVouchers: 1,
    avatarUrl: 'assets/images/Profile.png',
  );
}
