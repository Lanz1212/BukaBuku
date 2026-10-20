class ShippingAddress {
  final String id;
  final String recipientName;
  final String phoneNumber;
  final String label; // 'Rumah', 'Kantor', etc.
  final String fullAddress;
  final String? courierNote;
  final bool isPrimary;
  final bool isGeotagVerified;

  const ShippingAddress({
    required this.id,
    required this.recipientName,
    required this.phoneNumber,
    required this.label,
    required this.fullAddress,
    this.courierNote,
    this.isPrimary = false,
    this.isGeotagVerified = false,
  });

  ShippingAddress copyWith({
    String? id,
    String? recipientName,
    String? phoneNumber,
    String? label,
    String? fullAddress,
    String? courierNote,
    bool? isPrimary,
    bool? isGeotagVerified,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      courierNote: courierNote ?? this.courierNote,
      isPrimary: isPrimary ?? this.isPrimary,
      isGeotagVerified: isGeotagVerified ?? this.isGeotagVerified,
    );
  }

  static const List<ShippingAddress> defaultAddresses = [
    ShippingAddress(
      id: 'addr_001',
      recipientName: 'Budi Santoso',
      phoneNumber: '+62 812-3456-7890',
      label: 'Rumah',
      fullAddress:
          'Jl. Cikini Raya No. 45, RT 01 / RW 02, Kel. Cikini, Kec. Menteng, Jakarta Pusat, DKI Jakarta 10330',
      courierNote:
          'Rumah pagar hitam samping toko kelontong, titipkan satpam jika tidak ada orang.',
      isPrimary: true,
      isGeotagVerified: true,
    ),
    ShippingAddress(
      id: 'addr_002',
      recipientName: 'Budi Santoso (Kantor)',
      phoneNumber: '+62 812-3456-7890',
      label: 'Kantor',
      fullAddress:
          'Gedung Bursa Efek Indonesia Tower 2 Lt. 15, Jl. Jend. Sudirman Kav. 52-53, Senayan, Kebayoran Baru, Jakarta Selatan 12190',
      courierNote:
          'Kirim pada jam kerja (08.00 - 17.00 WIB), titipkan resepsionis lantai dasar.',
      isPrimary: false,
      isGeotagVerified: false,
    ),
  ];
}
