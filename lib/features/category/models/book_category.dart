import 'package:flutter/material.dart';

/// Model representing a curated book category in Toko Buku Budi
class BookCategory {
  final String id;
  final String name;
  final String bookCount;
  final IconData icon;

  const BookCategory({
    required this.id,
    required this.name,
    required this.bookCount,
    required this.icon,
  });

  /// Curated list of categories exactly as shown in the design
  static const List<BookCategory> defaultCategories = [
    BookCategory(
      id: 'novel',
      name: 'Novel',
      bookCount: '1.420 Buku',
      icon: Icons.auto_stories_outlined,
    ),
    BookCategory(
      id: 'komik',
      name: 'Komik',
      bookCount: '850 Buku',
      icon: Icons.forum_outlined,
    ),
    BookCategory(
      id: 'pendidikan',
      name: 'Pendidikan',
      bookCount: '2.100 Buku',
      icon: Icons.school_outlined,
    ),
    BookCategory(
      id: 'teknologi',
      name: 'Teknologi',
      bookCount: '640 Buku',
      icon: Icons.memory_outlined,
    ),
    BookCategory(
      id: 'bisnis',
      name: 'Bisnis',
      bookCount: '780 Buku',
      icon: Icons.trending_up_rounded,
    ),
    BookCategory(
      id: 'psikologi',
      name: 'Psikologi',
      bookCount: '520 Buku',
      icon: Icons.psychology_outlined,
    ),
    BookCategory(
      id: 'agama-religi',
      name: 'Agama & Religi',
      bookCount: '910 Buku',
      icon: Icons.account_balance_outlined,
    ),
    BookCategory(
      id: 'anak-dongeng',
      name: 'Anak & Dongeng',
      bookCount: '430 Buku',
      icon: Icons.star_outline_rounded,
    ),
  ];
}
