import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../models/book_search_item.dart';
import '../widgets/book_search_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_filter_chips.dart';
import '../../book_detail/screens/book_detail_screen.dart';

/// Screen for searching and browsing books in Toko Buku Budi
class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialCategory,
    this.initialQuery = 'Atomic Habits',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late Set<String> _selectedCategories;
  String _currentSort = 'Terpopuler';
  RangeValues _priceRange = const RangeValues(50000, 150000);
  String _selectedStockOption = 'instock';
  bool _forceEmptyPreview = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _selectedCategories = widget.initialCategory != null
        ? {widget.initialCategory!}
        : (widget.initialQuery.isNotEmpty ? {'Self-Help'} : {'Psikologi', 'Pengembangan Diri'});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          currentSort: _currentSort,
          initialCategories: _selectedCategories,
          initialPriceRange: _priceRange,
          initialStockOption: _selectedStockOption,
          onApply: (result) {
            setState(() {
              _currentSort = result.sortOption;
              _selectedCategories = result.categories;
              _priceRange = result.priceRange;
              _selectedStockOption = result.stockOption;
            });
          },
        );
      },
    );
  }

  void _openSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final options = [
          'Terbaru',
          'Harga termurah',
          'Harga tertinggi',
          'Terpopuler',
        ];
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Urutkan Hasil',
                style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...options.map((option) {
                final isSelected = option == _currentSort;
                return ListTile(
                  title: Text(
                    option,
                    style: AppTypography.bodyMd.copyWith(
                      color: isSelected ? AppColors.secondary : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: AppColors.secondary)
                      : null,
                  onTap: () {
                    setState(() {
                      _currentSort = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<BookSearchItem> get _displayBooks {
    final query = _searchController.text.trim().toLowerCase();
    var list = BookSearchItem.defaultSearchItems.where((book) {
      final matchesQuery = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);

      // Category matching
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.any((cat) {
            final c = cat.toLowerCase();
            final bookCat = book.category.toLowerCase();
            return bookCat.contains(c) ||
                c.contains(bookCat) ||
                (c.contains('pengembangan') && bookCat.contains('self-help')) ||
                (c.contains('psikologi') && (bookCat.contains('self-help') || book.title.toLowerCase().contains('habit')));
          });

      // Price matching
      final matchesPrice = book.priceValue >= _priceRange.start &&
          book.priceValue <= _priceRange.end;

      // Stock matching
      final matchesStock = _selectedStockOption == 'all' ||
          (_selectedStockOption == 'instock' && book.stockStatus != StockStatus.outOfStock) ||
          (_selectedStockOption == 'cikini' && book.shelfLocation != null);

      return matchesQuery && matchesCategory && matchesPrice && matchesStock;
    }).toList();

    // Sorting
    if (_currentSort == 'Harga: Rendah ke Tinggi' || _currentSort == 'Harga termurah') {
      list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
    } else if (_currentSort == 'Harga: Tinggi ke Rendah' || _currentSort == 'Harga tertinggi') {
      list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
    } else if (_currentSort == 'Rating Tertinggi') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final books = _displayBooks;
    final bool showEmpty = _forceEmptyPreview || books.isEmpty;
    final int activeFilterCount = _selectedCategories.length +
        (_selectedStockOption != 'all' ? 1 : 0);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Pencarian Buku',
        showBackButton: true,
        showShareButton: true,
        onSharePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tautan koleksi buku berhasil disalin!'),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        onProfilePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Membuka profil pembaca...'),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search & Filter Control Hub
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 22,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari judul, penulis, atau ISBN...',
                                hintStyle: AppTypography.bodyMd.copyWith(
                                  color: AppColors.outline,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (_) {
                                setState(() {
                                  _forceEmptyPreview = false;
                                });
                              },
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _forceEmptyPreview = false;
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.close,
                                  size: 15,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Filter Quick Tools Bar
                    SearchFilterChips(
                      activeFilterCount: activeFilterCount,
                      currentSort: _currentSort,
                      activeCategory: _selectedCategories.isNotEmpty
                          ? (_selectedCategories.length == 1
                              ? _selectedCategories.first
                              : '${_selectedCategories.first} +${_selectedCategories.length - 1}')
                          : null,
                      onFilterTap: _openFilterBottomSheet,
                      onSortTap: _openSortMenu,
                      onClearCategory: () {
                        setState(() {
                          _selectedCategories.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // State Preview Selector Switch (UX Testing Mode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _forceEmptyPreview = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !showEmpty
                                  ? AppColors.surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: !showEmpty
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryContainer.withValues(alpha: 0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: !showEmpty
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Hasil Ditemukan (12)',
                                  style: AppTypography.labelMd.copyWith(
                                    color: !showEmpty
                                        ? AppColors.primaryContainer
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: !showEmpty ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _forceEmptyPreview = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: showEmpty
                                  ? AppColors.surfaceContainerLowest
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: showEmpty
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryContainer.withValues(alpha: 0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 16,
                                  color: showEmpty
                                      ? AppColors.primaryContainer
                                      : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pratinjau Kosong',
                                  style: AppTypography.labelMd.copyWith(
                                    color: showEmpty
                                        ? AppColors.primaryContainer
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: showEmpty ? FontWeight.w600 : FontWeight.w500,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content View (Results or Empty State)
              if (showEmpty)
                SearchEmptyState(
                  onShowRecommendations: () {
                    setState(() {
                      _forceEmptyPreview = false;
                      _searchController.text = 'Atomic Habits';
                      _selectedCategories = {'Self-Help'};
                    });
                  },
                  onClearKeywords: () {
                    setState(() {
                      _forceEmptyPreview = false;
                      _searchController.clear();
                      _selectedCategories.clear();
                    });
                  },
                )
              else ...[
                // Results Counter & Shelving Info Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          children: [
                            const TextSpan(text: 'Menampilkan '),
                            TextSpan(
                              text: '12 hasil',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const TextSpan(text: ' untuk '),
                            TextSpan(
                              text: '"${_searchController.text.isNotEmpty ? _searchController.text : "Semua"}"',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Toko Fisik & Online Selaras',
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2-Column Book Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: books.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.50,
                    ),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookSearchCard(
                        book: book,
                        onAddToCart: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${book.title} ditambahkan ke keranjang belanja'),
                              backgroundColor: AppColors.primaryContainer,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        onNotifyMe: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Notifikasi ketersediaan disetel untuk ${book.title}'),
                              backgroundColor: AppColors.primaryContainer,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(searchItem: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
