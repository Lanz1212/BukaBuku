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
        storeName: 'Toko Buku Budi (Gerai Utama Cikini)',
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
}
