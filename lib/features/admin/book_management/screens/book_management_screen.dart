import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_book_item.dart';
import '../widgets/book_management_card.dart';
import '../widgets/book_management_filter.dart';
import 'add_book_screen.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<AdminBookItem> _books = List.from(AdminBookItem.mockBooks);
  int _selectedCategoryIndex = 0;

  final List<BookCategoryFilterItem> _categories = const [
    BookCategoryFilterItem('Semua', 150),
    BookCategoryFilterItem('Novel', 45),
    BookCategoryFilterItem('Non-Fiksi', 32),
    BookCategoryFilterItem('Pengembangan Diri', 28),
    BookCategoryFilterItem('Komik', 25),
    BookCategoryFilterItem('Pendidikan', 20),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminBookItem> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCat = _categories[_selectedCategoryIndex].label;

    return _books.where((book) {
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);

      final matchesCategory =
          selectedCat == 'Semua' || book.category == selectedCat;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBookStatus(int index, AdminBookItem book) {
    setState(() {
      final actualIndex = _books.indexWhere((b) => b.id == book.id);
      if (actualIndex != -1) {
        final newStatus = !_books[actualIndex].isActive;
        _books[actualIndex] = _books[actualIndex].copyWith(isActive: newStatus);
        _showNotice(
          newStatus
              ? '"${book.title}" kembali aktif dijual'
              : '"${book.title}" dinonaktifkan dari katalog online',
        );
      }
    });
  }

  void _deleteBook(AdminBookItem book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Buku?',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${book.title}" dari katalog inventaris?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.titleMd.copyWith(
                fontSize: 14,
                color: AppColors.outline,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _books.removeWhere((b) => b.id == book.id);
              });
              _showNotice('"${book.title}" berhasil dihapus dari inventaris');
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddBook() async {
    final newBook = await Navigator.push<AdminBookItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBookScreen(),
      ),
    );

    if (newBook != null) {
      setState(() {
        _books.insert(0, newBook);
      });
      _showNotice('Buku "${newBook.title}" berhasil ditambahkan ke rak');
    }
  }

  Future<void> _navigateToEditBook(AdminBookItem book) async {
    final updatedBook = await Navigator.push<AdminBookItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookScreen(initialBook: book),
      ),
    );

    if (updatedBook != null) {
      setState(() {
        final index = _books.indexWhere((b) => b.id == updatedBook.id);
        if (index != -1) {
          _books[index] = updatedBook;
        }
      });
      _showNotice('Buku "${updatedBook.title}" berhasil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedBooks = _filteredBooks;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Header with Title & Total Books Pill
              _buildHeader(),
              const SizedBox(height: 14),

              // Search Input & Category Filters
              BookManagementFilter(
                searchController: _searchController,
                onSearchChanged: (val) => setState(() {}),
                onFilterTuneTap: () =>
                    _showNotice('Filter lanjutan: Rentang harga, stok, rak'),
                selectedCategoryIndex: _selectedCategoryIndex,
                onCategorySelected: (idx) {
                  setState(() {
                    _selectedCategoryIndex = idx;
                  });
                },
                categories: _categories,
              ),
              const SizedBox(height: 16),

              // Sort Row & Item count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Terakhir diperbarui',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Menampilkan ${displayedBooks.length} dari ${_books.length}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Books List
              if (displayedBooks.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedBooks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = displayedBooks[index];
                    return BookManagementCard(
                      book: book,
                      onToggleStatus: () => _toggleBookStatus(index, book),
                      onEdit: () => _navigateToEditBook(book),
                      onDelete: () => _deleteBook(book),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // Periodic Stock Audit Banner
              _buildStockAuditBanner(),
            ],
          ),
        ),

        // Floating Action Button: Tambah Buku Baru
        Positioned(
          bottom: 16,
          right: 16,
          child: ElevatedButton.icon(
            onPressed: _navigateToAddBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
              elevation: 6,
              shadowColor: AppColors.primaryContainer.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            label: Text(
              'Tambah Buku Baru',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kelola Buku',
              style: AppTypography.headlineMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Katalog toko fisik & inventaris online',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 15,
                color: AppColors.onSecondaryContainer,
              ),
              const SizedBox(width: 5),
              Text(
                '${_books.length} Judul',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada buku ditemukan',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau kategori filter',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStockAuditBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.onSecondaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemeriksaan Berkala Stok',
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '2 buku stok menipis siap dipesan kembali ke distributor Gramedia.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
