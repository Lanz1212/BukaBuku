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
