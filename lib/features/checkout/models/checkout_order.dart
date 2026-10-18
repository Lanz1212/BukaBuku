import 'package:flutter/material.dart';

enum FulfillmentMode {
  delivery,
  pickup,
}

class DeliveryAddress {
  final String recipientName;
  final String phone;
  final String address;
  final String notes;

  const DeliveryAddress({
    this.recipientName = 'Budi Santoso',
    this.phone = '0812-3456-7890',
    this.address =
        'Jl. Cikini Raya No. 42, RT 05 / RW 01, Menteng, Jakarta Pusat, DKI Jakarta 10330',
    this.notes = 'Titipkan di meja resepsionis jika tidak di tempat.',
  });
}

class StoreInfo {
  final String name;
  final String badge;
  final String address;
  final String operatingHours;
  final String phone;
  final String mapImageUrl;

  const StoreInfo({
    this.name = 'Toko Buku Budi (Pusat Cikini)',
    this.badge = 'Toko Utama',
    this.address = 'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat',
    this.operatingHours = '08.00 – 21.00 WIB',
    this.phone = '0812-3456-7890',
    this.mapImageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBQiMYpuICxvQwf1WHsFMJsFHrwOfJo1uj1ZkiL9T7SMi8TKpRGoBLbKTrPS06aipGF5-C5ikeKYhI9-hPVq5JswonAST4ugvVjGig-1GJRqzcKEK5AD16cBd1NDkNclsPigiNGZ3vSUhDm3KHXsYfn2KPly0JD8OpbUUYf9z-4Q1EFhJCuZtP5YJd15TLBy3Xj7kgYkhwPg8I-QnlO7YT1mJ3EKi1beppJcZaoXwofI6j2GvK5m_34CQ',
  });
}

class PaymentMethodOption {
  final String id;
  final String title;
  final String? badge;
  final String subtitle;
  final IconData icon;

  const PaymentMethodOption({
    required this.id,
    required this.title,
    this.badge,
    required this.subtitle,
    required this.icon,
  });

  static const List<PaymentMethodOption> allOptions = [
    PaymentMethodOption(
      id: 'qris',
      title: 'QRIS Instant',
      badge: 'Bebas Biaya',
      subtitle: 'GoPay, OVO, BCA, DANA, ShopeePay',
      icon: Icons.qr_code_2,
    ),
    PaymentMethodOption(
      id: 'va',
      title: 'Transfer Virtual Account',
      subtitle: 'BCA, Mandiri, BNI, BRI',
      icon: Icons.account_balance_outlined,
    ),
    PaymentMethodOption(
      id: 'cash',
      title: 'Bayar di Kasir (Cash / Kartu)',
      subtitle: 'Bayar tunai di meja kasir Cikini saat pengambilan',
      icon: Icons.point_of_sale_outlined,
    ),
  ];
}
