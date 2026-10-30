import 'package:flutter/material.dart';

class AdminCategoryItem {
  final String id;
  final String name;
  final String code;
  final String rackLocation;
  final int floor; // 1 or 2
  final int bookCount;
  final IconData icon;

  const AdminCategoryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.rackLocation,
    required this.floor,
    required this.bookCount,
    required this.icon,
  });

  AdminCategoryItem copyWith({
    String? id,
    String? name,
    String? code,
    String? rackLocation,
    int? floor,
    int? bookCount,
    IconData? icon,
  }) {
    return AdminCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      rackLocation: rackLocation ?? this.rackLocation,
      floor: floor ?? this.floor,
      bookCount: bookCount ?? this.bookCount,
      icon: icon ?? this.icon,
    );
  }

  static List<AdminCategoryItem> get mockCategories => [
        const AdminCategoryItem(
          id: 'cat-01',
          name: 'Novel & Fiksi',
          code: 'NVL-01',
          rackLocation: 'Rak A1 - Lantai 1',
          floor: 1,
          bookCount: 45,
          icon: Icons.auto_stories_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-02',
          name: 'Komik & Manga',
          code: 'KMK-02',
          rackLocation: 'Rak B1 - Lantai 1',
          floor: 1,
          bookCount: 28,
          icon: Icons.menu_book_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-03',
          name: 'Pendidikan & Sekolah',
          code: 'PDK-03',
          rackLocation: 'Rak C1 - Lantai 1',
          floor: 1,
          bookCount: 34,
          icon: Icons.school_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-04',
          name: 'Teknologi & Komputer',
          code: 'TEK-04',
          rackLocation: 'Rak D1 - Lantai 2',
          floor: 2,
          bookCount: 18,
          icon: Icons.computer_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-05',
          name: 'Bisnis & Keuangan',
          code: 'BSN-05',
          rackLocation: 'Rak B2 - Lantai 1',
          floor: 1,
          bookCount: 22,
          icon: Icons.trending_up_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-06',
          name: 'Psikologi & Self-Help',
          code: 'PSI-06',
          rackLocation: 'Rak B3 - Lantai 1',
          floor: 1,
          bookCount: 16,
          icon: Icons.psychology_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-07',
          name: 'Agama & Spiritualitas',
          code: 'AGM-07',
          rackLocation: 'Rak E1 - Lantai 2',
          floor: 2,
          bookCount: 20,
          icon: Icons.import_contacts_rounded,
        ),
        const AdminCategoryItem(
          id: 'cat-08',
          name: 'Buku Anak & Balita',
          code: 'ANK-08',
          rackLocation: 'Rak F1 - Lantai 2',
          floor: 2,
          bookCount: 14,
          icon: Icons.toys_rounded,
        ),
      ];
}
