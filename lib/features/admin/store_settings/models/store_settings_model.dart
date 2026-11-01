/// Store Settings Model for Toko Buku Budi
class StoreSettingsModel {
  final String storeName;
  final String branchName;
  final String address;
  final String district;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String whatsappNumber;
  final String openTime;
  final String closeTime;
  final String operatingDays;
  final String description;
  final int maxPickupHours;
  final String photoPath;

  const StoreSettingsModel({
    required this.storeName,
    required this.branchName,
    required this.address,
    required this.district,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.openTime,
    required this.closeTime,
    required this.operatingDays,
    required this.description,
    required this.maxPickupHours,
    required this.photoPath,
  });

  String get fullAddress =>
      '$address, $district, $city, $postalCode';

  static StoreSettingsModel get initialData => const StoreSettingsModel(
        storeName: 'Toko Buku Budi (Pusat Cikini)',
        branchName: 'Gerai Cikini',
        address: 'Jl. Cikini Raya No. 45, RT.01/RW.02, Cikini, Kec. Menteng',
        district: 'Menteng',
        city: 'Kota Jakarta Pusat, DKI Jakarta',
        postalCode: '10330',
        latitude: -6.1912,
        longitude: 106.8404,
        phoneNumber: '021-3190-8822',
        whatsappNumber: '0812-9988-7711',
        openTime: '08:00 WIB',
        closeTime: '21:00 WIB',
        operatingDays: 'Buka Setiap Hari (Senin - Minggu)',
        description:
            'Toko buku independen dan ruang baca tenang di jantung Cikini. Menghadirkan kurasi literatur pilihan, sastra klasik, pengembangan diri, serta layanan pengambilan buku langsung di gerai bebas biaya.',
        maxPickupHours: 48,
        photoPath: 'assets/images/bookstore_camera_sim.jpg',
      );

  StoreSettingsModel copyWith({
    String? storeName,
    String? branchName,
    String? address,
    String? district,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? whatsappNumber,
    String? openTime,
    String? closeTime,
    String? operatingDays,
    String? description,
    int? maxPickupHours,
    String? photoPath,
  }) {
    return StoreSettingsModel(
      storeName: storeName ?? this.storeName,
      branchName: branchName ?? this.branchName,
      address: address ?? this.address,
      district: district ?? this.district,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      operatingDays: operatingDays ?? this.operatingDays,
      description: description ?? this.description,
      maxPickupHours: maxPickupHours ?? this.maxPickupHours,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  factory StoreSettingsModel.fromSupabase(Map<String, dynamic> data) {
    return StoreSettingsModel(
      storeName: data['store_name']?.toString() ?? initialData.storeName,
      branchName: data['branch_name']?.toString() ?? initialData.branchName,
      address: data['address']?.toString() ?? initialData.address,
      district: data['district']?.toString() ?? initialData.district,
      city: data['city']?.toString() ?? initialData.city,
      postalCode: data['postal_code']?.toString() ?? initialData.postalCode,
      latitude: (data['latitude'] as num?)?.toDouble() ?? initialData.latitude,
      longitude: (data['longitude'] as num?)?.toDouble() ?? initialData.longitude,
      phoneNumber: data['phone_number']?.toString() ?? initialData.phoneNumber,
      whatsappNumber: data['whatsapp_number']?.toString() ?? initialData.whatsappNumber,
      openTime: data['open_time']?.toString() ?? initialData.openTime,
      closeTime: data['close_time']?.toString() ?? initialData.closeTime,
      operatingDays: data['operating_days']?.toString() ?? initialData.operatingDays,
      description: data['description']?.toString() ?? initialData.description,
      maxPickupHours: (data['max_pickup_hours'] as num?)?.toInt() ?? initialData.maxPickupHours,
      photoPath: data['photo_path']?.toString() ?? initialData.photoPath,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'store_name': storeName,
      'branch_name': branchName,
      'address': address,
      'district': district,
      'city': city,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'open_time': openTime,
      'close_time': closeTime,
      'operating_days': operatingDays,
      'description': description,
      'max_pickup_hours': maxPickupHours,
      'photo_path': photoPath,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
