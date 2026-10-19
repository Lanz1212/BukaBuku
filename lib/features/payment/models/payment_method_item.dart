import 'package:flutter/material.dart';

enum PaymentCategory {
  instantDigital,
  onSite,
}

/// Model representing a payment method option for Toko Buku Budi.
/// Follows DESIGN.md and Google Stitch Mobile UI reference.
class PaymentMethodItem {
  final String id;
  final PaymentCategory category;
  final String title;
  final String subtitle;
  final String? badge;
  final IconData? icon;
  final String? subline;
  final IconData? sublineIcon;
  final List<String> chips;
  final bool requiresPickupOnly;
  final bool isFastest;

  const PaymentMethodItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    this.badge,
    this.icon,
    this.subline,
    this.sublineIcon,
    this.chips = const [],
    this.requiresPickupOnly = false,
    this.isFastest = false,
  });

  /// Default options matching the reference mockups and Stitch screens
  static const List<PaymentMethodItem> defaultMethods = [
    // 1. Category: Pembayaran Instan & Digital
    PaymentMethodItem(
      id: 'qris',
      category: PaymentCategory.instantDigital,
      title: 'QRIS (Semua Pembayaran)',
      subtitle:
          'Scan instan via BCA Mobile, GoPay, OVO, Dana, ShopeePay & LinkAja.',
      badge: 'Paling Cepat',
      isFastest: true,
      chips: ['QRIS', 'BCA', 'GoPay', 'OVO', '+3 Lainnya'],
    ),
    PaymentMethodItem(
      id: 'va',
      category: PaymentCategory.instantDigital,
      title: 'Virtual Account Bank',
      subtitle:
          'BCA, Mandiri, BNI, BRI, BSI. Verifikasi otomatis 24 jam tanpa upload bukti bayar.',
      icon: Icons.account_balance_outlined,
      subline: 'Konfirmasi instan • Bayar via m-Banking/ATM',
      sublineIcon: Icons.verified_outlined,
    ),
    PaymentMethodItem(
      id: 'ewallet',
      category: PaymentCategory.instantDigital,
      title: 'Dompet Digital (E-Wallet)',
      subtitle:
          'Hubungkan akun GoPay, OVO, atau Dana langsung untuk proses checkout 1-klik yang praktis.',
      icon: Icons.account_balance_wallet_outlined,
    ),

    // 2. Category: Pembayaran di Tempat
    PaymentMethodItem(
      id: 'cash',
      category: PaymentCategory.onSite,
      title: 'Cash Saat Pengambilan',
      subtitle:
          'Bayar tunai di meja kasir saat mengambil buku di Toko Buku Budi Cikini.',
      badge: 'Ambil di Toko',
      icon: Icons.store_outlined,
      subline: 'Buku disisihkan hingga 3 hari kerja',
      sublineIcon: Icons.info_outline,
      requiresPickupOnly: true,
    ),
  ];
}
