import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/book_service.dart';
import '../../../../core/services/cashier_log_service.dart';
import '../models/admin_book_item.dart';
import '../widgets/book_management_card.dart';
import '../widgets/book_management_filter.dart';
import '../widgets/admin_book_filter_modal.dart';
import '../../category_management/screens/category_management_screen.dart';
import 'add_book_screen.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AdminBookItem> _books = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedCategoryIndex = 0;
  List<BookCategoryFilterItem> _categories = [];

  // Filter lanjutan state
  RangeValues? _minMaxPrice;
  RangeValues? _selectedPriceRange;
  String _selectedStockFilter = 'Semua'; // 'Semua', 'Tersedia', 'Menipis', 'Habis'
  String? _selectedRack; // null / 'Semua' / string rak

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await BookService.fetchBooks();
      _rebuildCategories(books);

      int minP = 0;
      int maxP = 500000;
      if (books.isNotEmpty) {
        minP = books.map((b) => b.price).reduce((a, b) => a < b ? a : b);
        maxP = books.map((b) => b.price).reduce((a, b) => a > b ? a : b);
        if (minP == maxP) {
          maxP = minP + 50000;
        }
      }
      final computedMinMax = RangeValues(minP.toDouble(), maxP.toDouble());

      if (mounted) {
        setState(() {
          _books = books;
          _minMaxPrice = computedMinMax;
          if (_selectedPriceRange == null) {
            _selectedPriceRange = computedMinMax;
          } else {
            _selectedPriceRange = RangeValues(
              _selectedPriceRange!.start.clamp(computedMinMax.start, computedMinMax.end),
              _selectedPriceRange!.end.clamp(computedMinMax.start, computedMinMax.end),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _rebuildCategories(List<AdminBookItem> books) {
    final Map<String, int> catCounts = {};
    for (final b in books) {
      catCounts[b.category] = (catCounts[b.category] ?? 0) + 1;
    }

    final List<BookCategoryFilterItem> items = [
      BookCategoryFilterItem('Semua', books.length),
    ];

    catCounts.forEach((catName, count) {
      items.add(BookCategoryFilterItem(catName, count));
    });

    _categories = items;
    if (_selectedCategoryIndex >= _categories.length) {
      _selectedCategoryIndex = 0;
    }
  }

  List<String> get _availableRacks {
    final racks = _books
        .map((b) => b.rackLocation.trim())
        .where((r) => r.isNotEmpty)
        .toSet()
        .toList();
    racks.sort();
    return racks;
  }

  bool get _hasActiveAdvancedFilter {
    final isPriceFiltered = _minMaxPrice != null &&
        _selectedPriceRange != null &&
        (_selectedPriceRange!.start > _minMaxPrice!.start ||
            _selectedPriceRange!.end < _minMaxPrice!.end);
    final isStockFiltered = _selectedStockFilter != 'Semua';
    final isRackFiltered = _selectedRack != null && _selectedRack != 'Semua';
    return isPriceFiltered || isStockFiltered || isRackFiltered;
  }

  void _resetAdvancedFilters() {
    setState(() {
      if (_minMaxPrice != null) {
        _selectedPriceRange = _minMaxPrice;
      }
      _selectedStockFilter = 'Semua';
      _selectedRack = 'Semua';
    });
  }

  void _openFilterModal() {
    if (_minMaxPrice == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AdminBookFilterModal(
          minMaxPrice: _minMaxPrice!,
          currentPriceRange: _selectedPriceRange ?? _minMaxPrice!,
          currentStockFilter: _selectedStockFilter,
          currentRackFilter: _selectedRack,
          availableRacks: _availableRacks,
          onApply: (priceRange, stockFilter, rackFilter) {
            setState(() {
              _selectedPriceRange = priceRange;
              _selectedStockFilter = stockFilter;
              _selectedRack = rackFilter;
            });
          },
          onReset: _resetAdvancedFilters,
        );
      },
    );
  }

  List<AdminBookItem> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCat = _categories.isNotEmpty && _selectedCategoryIndex < _categories.length
        ? _categories[_selectedCategoryIndex].label
        : 'Semua';

    return _books.where((book) {
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query) ||
          book.rackLocation.toLowerCase().contains(query);

      final matchesCategory =
          selectedCat == 'Semua' || book.category == selectedCat;

      final matchesPrice = _selectedPriceRange == null ||
          (book.price >= _selectedPriceRange!.start &&
              book.price <= _selectedPriceRange!.end);

      final matchesStock = _selectedStockFilter == 'Semua' ||
          (_selectedStockFilter == 'Tersedia' &&
              book.status == AdminBookStatus.tersedia) ||
          (_selectedStockFilter == 'Menipis' &&
              book.status == AdminBookStatus.menipis) ||
          (_selectedStockFilter == 'Habis' &&
              (book.status == AdminBookStatus.outOfStock || book.stock <= 0));

      final matchesRack = _selectedRack == null ||
          _selectedRack == 'Semua' ||
          book.rackLocation == _selectedRack;

      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesStock &&
          matchesRack;
    }).toList();
  }

  void _showNotice(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleBookStatus(int index, AdminBookItem book) async {
    final newStatus = !book.isActive;
    try {
      await BookService.toggleBookStatus(book.id, newStatus);
      CashierLogService.recordLog(
        action: 'Ubah Status Katalog Buku',
        details:
            'Mengubah status buku "${book.title}" menjadi ${newStatus ? "Aktif" : "Nonaktif"}',
        tag: 'Inventaris',
      );
      setState(() {
        final actualIndex = _books.indexWhere((b) => b.id == book.id);
        if (actualIndex != -1) {
          _books[actualIndex] = _books[actualIndex].copyWith(isActive: newStatus);
        }
      });
      _showNotice(
        newStatus
            ? '"${book.title}" kembali aktif dijual di toko'
            : '"${book.title}" dinonaktifkan dari katalog toko',
      );
    } catch (e) {
      _showNotice('Gagal mengubah status: $e', isError: true);
    }
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
          'Apakah Anda yakin ingin menghapus "${book.title}" dari database inventaris?',
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await BookService.deleteBook(book.id);
                CashierLogService.recordLog(
                  action: 'Hapus Buku',
                  details:
                      'Menghapus buku "${book.title}" (ID: ${book.id}) dari database inventaris',
                  tag: 'Inventaris',
                );
                setState(() {
                  _books.removeWhere((b) => b.id == book.id);
                  _rebuildCategories(_books);
                });
                _showNotice('"${book.title}" berhasil dihapus dari database');
              } catch (e) {
                _showNotice('Gagal menghapus buku: $e', isError: true);
              }
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
      await _loadBooks();
      _showNotice('Buku "${newBook.title}" berhasil ditambahkan ke inventaris');
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
      await _loadBooks();
      _showNotice('Buku "${updatedBook.title}" berhasil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedBooks = _filteredBooks;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadBooks,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Page Header with Title & Total Books Pill
                _buildHeader(),
                const SizedBox(height: 14),

                // Search Input & Category Filters
                if (_categories.isNotEmpty)
                  BookManagementFilter(
                    searchController: _searchController,
                    onSearchChanged: (val) => setState(() {}),
                    onFilterTuneTap: _openFilterModal,
                    hasActiveFilter: _hasActiveAdvancedFilter,
                    selectedCategoryIndex: _selectedCategoryIndex,
                    onCategorySelected: (idx) {
                      setState(() {
                        _selectedCategoryIndex = idx;
                      });
                    },
                    categories: _categories,
                  ),
                if (_hasActiveAdvancedFilter) ...[
                  const SizedBox(height: 8),
                  _buildActiveFilterChips(),
                ],
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
                          'Data Database Real-time',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Menampilkan ${displayedBooks.length} dari ${_books.length} buku',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Loading State
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Error State
                else if (_errorMessage != null)
                  _buildErrorState()
                // Empty State
                else if (displayedBooks.isEmpty)
                  _buildEmptyState()
                // Books List
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

  Widget _buildActiveFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_selectedStockFilter != 'Semua')
            _buildActiveChip('Stok: $_selectedStockFilter', () {
              setState(() => _selectedStockFilter = 'Semua');
            }),
          if (_selectedRack != null && _selectedRack != 'Semua')
            _buildActiveChip('Rak: $_selectedRack', () {
              setState(() => _selectedRack = 'Semua');
            }),
          if (_minMaxPrice != null &&
              _selectedPriceRange != null &&
              (_selectedPriceRange!.start > _minMaxPrice!.start ||
                  _selectedPriceRange!.end < _minMaxPrice!.end))
            _buildActiveChip(
              'Harga: Rp ${(_selectedPriceRange!.start / 1000).round()}k - Rp ${(_selectedPriceRange!.end / 1000).round()}k',
              () {
                setState(() => _selectedPriceRange = _minMaxPrice);
              },
            ),
          TextButton(
            onPressed: _resetAdvancedFilters,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'Reset Semua',
              style: AppTypography.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
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
              'Katalog toko fisik & inventaris database',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryManagementScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.category_outlined, size: 14),
              label: Text(
                'Kategori',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                    Icons.auto_stories_rounded,
                    size: 13,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_books.length} Buku',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
          const SizedBox(height: 8),
          Text(
            'Gagal Memuat Data Database',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage ?? 'Terjadi kesalahan jaringan',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 12.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBooks,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada buku yang cocok',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau pilih kategori lain.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 12.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockAuditBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_rounded,
              color: AppColors.onPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Stok Database',
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Data katalog tersinkronisasi otomatis dengan server Supabase',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
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
