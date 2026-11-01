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

  factory AdminCategoryItem.fromMap(
    Map<String, dynamic> map, {
    int bookCount = 0,
  }) {
    final code = map['code'] as String? ?? '';
    final imageUrl = map['image_url'] as String?;

    return AdminCategoryItem(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      code: code,
      rackLocation: map['rack_location'] as String? ?? '',
      floor: map['floor'] as int? ?? 1,
      bookCount: bookCount,
      icon: iconFromIdentifier(imageUrl, code: code),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'rack_location': rackLocation,
      'floor': floor,
      'image_url': identifierFromIcon(icon),
    };
  }

  static const Map<String, IconData> _iconMap = {
    'auto_stories': Icons.auto_stories_rounded,
    'menu_book': Icons.menu_book_rounded,
    'school': Icons.school_rounded,
    'computer': Icons.computer_rounded,
    'trending_up': Icons.trending_up_rounded,
    'psychology': Icons.psychology_rounded,
    'import_contacts': Icons.import_contacts_rounded,
    'toys': Icons.toys_rounded,
    'science': Icons.science_rounded,
    'palette': Icons.palette_rounded,
    'history_edu': Icons.history_edu_rounded,
    'public': Icons.public_rounded,
  };

  static IconData iconFromIdentifier(String? identifier, {String? code}) {
    if (identifier != null && identifier.startsWith('icon:')) {
      final key = identifier.substring(5);
      if (_iconMap.containsKey(key)) {
        return _iconMap[key]!;
      }
    }

    final c = (code ?? '').toUpperCase();
    if (c.contains('NVL')) return Icons.auto_stories_rounded;
    if (c.contains('KMK')) return Icons.menu_book_rounded;
    if (c.contains('PDK')) return Icons.school_rounded;
    if (c.contains('TEK')) return Icons.computer_rounded;
    if (c.contains('BSN')) return Icons.trending_up_rounded;
    if (c.contains('PSI') || c.contains('SLF')) return Icons.psychology_rounded;
    if (c.contains('AGM') || c.contains('FLS')) return Icons.import_contacts_rounded;
    if (c.contains('ANK')) return Icons.toys_rounded;
    if (c.contains('SJR')) return Icons.history_edu_rounded;

    return Icons.auto_stories_rounded;
  }

  static String identifierFromIcon(IconData icon) {
    for (final entry in _iconMap.entries) {
      if (entry.value == icon) {
        return 'icon:${entry.key}';
      }
    }
    return 'icon:auto_stories';
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
