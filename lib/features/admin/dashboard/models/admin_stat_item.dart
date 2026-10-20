import 'package:flutter/material.dart';

class AdminStatItem {
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final IconData icon;
  final bool isHighlight;
  final String? badgeText;

  const AdminStatItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.icon,
    this.isHighlight = false,
    this.badgeText,
  });

  static List<AdminStatItem> get mockStats => const [
        AdminStatItem(
          title: 'Total Buku',
          value: '150',
          unit: 'judul',
          subtitle: '+4 baru minggu ini',
          icon: Icons.menu_book_outlined,
        ),
        AdminStatItem(
          title: 'Pesanan Hari Ini',
          value: '12',
          unit: 'pesanan',
          subtitle: '8 Selesai',
          icon: Icons.shopping_bag_outlined,
        ),
        AdminStatItem(
          title: 'Pesanan Baru',
          value: '5',
          unit: 'pesanan',
          subtitle: 'Prioritas pickup toko',
          icon: Icons.pending_actions_rounded,
          isHighlight: true,
          badgeText: 'Perlu Proses',
        ),
        AdminStatItem(
          title: 'Penjualan Hari Ini',
          value: 'Rp2.350.000',
          unit: '',
          subtitle: '+15% vs kemarin',
          icon: Icons.trending_up_rounded,
        ),
      ];
}
