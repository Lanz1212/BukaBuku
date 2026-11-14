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
          value: '0',
          unit: 'judul',
          subtitle: '0 total eksemplar',
          icon: Icons.menu_book_outlined,
        ),
        AdminStatItem(
          title: 'Total Pesanan',
          value: '0',
          unit: 'pesanan',
          subtitle: 'Tersinkron Supabase',
          icon: Icons.shopping_bag_outlined,
        ),
        AdminStatItem(
          title: 'Pesanan Baru',
          value: '0',
          unit: 'pesanan',
          subtitle: 'Prioritas pemrosesan',
          icon: Icons.pending_actions_rounded,
          isHighlight: true,
          badgeText: 'Perlu Proses',
        ),
        AdminStatItem(
          title: 'Total Transaksi',
          value: 'Rp0',
          unit: '',
          subtitle: 'Lunas terverifikasi',
          icon: Icons.trending_up_rounded,
        ),
      ];
}
