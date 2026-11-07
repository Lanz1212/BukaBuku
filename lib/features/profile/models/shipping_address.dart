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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'label': label,
      'fullAddress': fullAddress,
      'courierNote': courierNote,
      'isPrimary': isPrimary,
      'isGeotagVerified': isGeotagVerified,
    };
  }

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      id: map['id']?.toString() ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      recipientName: map['recipientName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Alamat',
      fullAddress: map['fullAddress']?.toString() ?? '',
      courierNote: map['courierNote']?.toString(),
      isPrimary: map['isPrimary'] == true,
      isGeotagVerified: map['isGeotagVerified'] == true,
    );
  }

  static const List<ShippingAddress> defaultAddresses = [];
}
