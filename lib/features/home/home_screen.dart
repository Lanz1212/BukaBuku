import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../category/screens/category_screen.dart';
import '../search/screens/search_screen.dart';
import '../book_detail/screens/book_detail_screen.dart';
import '../book_detail/models/book_detail.dart';
import '../../core/services/book_service.dart';
import '../admin/book_management/models/admin_book_item.dart';
import '../cart/screens/cart_screen.dart';
import '../favorite/screens/favorite_screen.dart';
import '../order/screens/order_list_screen.dart';
import '../notification/screens/notification_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../../shared/widgets/bookstore_bottom_nav.dart';

/// Home Page — Buka Buku
/// Design: DESIGN.md | AppColors | AppTypography
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  List<AdminBookItem> _books = [];
  List<AdminBookItem> _topRatedBooks = [];
  List<String> _categories = ['Semua'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        BookService.fetchBooks(onlyActive: true),
        BookService.fetchTopRatedBooks(limit: 10),
        BookService.fetchCategoryNames(),
      ]);
      if (mounted) {
        setState(() {
          _books = results[0] as List<AdminBookItem>;
          _topRatedBooks = results[1] as List<AdminBookItem>;
          _categories = ['Semua', ...(results[2] as List<String>)];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<AdminBookItem> get _filteredBooks {
    if (_selectedCategory == 0 || _categories.isEmpty) return _books;
    final selectedCat = _categories[_selectedCategory].toLowerCase();
    return _books.where((b) {
      final cat = b.category.toLowerCase();
      return cat == selectedCat || cat.contains(selectedCat) || selectedCat.contains(cat);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primaryContainer,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Categories
                      _buildCategories(),
                      const SizedBox(height: 24),

                      // Featured Books / Rekomendasi
                      _buildSectionTitle(
                        'Buku Rekomendasi',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(
                                initialSort: 'Terpopuler',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildFeaturedBooks(),
                      const SizedBox(height: 24),

                      // New Arrivals / Filtered
                      _buildSectionTitle(
                        _selectedCategory == 0
                            ? 'Buku Terbaru'
                            : 'Buku ${_categories[_selectedCategory]}',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(
                                initialCategory: _selectedCategory == 0 ? null : _categories[_selectedCategory],
                                initialSort: 'Terbaru',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildNewArrivals(),
                      const SizedBox(height: 24),

                      // Koleksi Populer (Direct books replacing promo banner)
                      _buildSectionTitle(
                        'Koleksi Populer',
                        onSeeAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(
                                initialSort: 'Terpopuler',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildPopularCollection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Home
              Row(
                children: [
                  Image.asset(
                    'assets/images/Logo Toko Buku Budi.png',
                    width: 48, // <-- UBAH ANGKA INI UNTUK UKURAN GAMBAR
                    height: 48, // <-- SAMAKAN DENGAN WIDTH
                    fit: BoxFit.contain, // <-- WAJIB DITAMBAHKAN AGAR GAMBAR IKUT MEMBESAR/MENGECIL
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48, // <-- SAMAKAN UKURANNYA DI SINI JUGA
                        height: 48, // <-- SAMAKAN UKURANNYA DI SINI JUGA
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 36, // <-- SESUAIKAN UKURAN ICON AGAR PAS
                          color: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buka Buku',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Home',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Search and Profile
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoriteScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Profile.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 20,
                              color: AppColors.onPrimary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting Section
          Row(
            children: [
              // Profile Picture
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Profile.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 28,
                        color: AppColors.onSurfaceVariant,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Greeting Text and Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Budi 👋',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 12,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pembaca Setia',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Notification Bell
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  _categories[index],
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.onPrimary
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: Text(
            'Lihat Semua',
            style: AppTypography.labelMd.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBooks() {
    if (_isLoading) {
      return const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final featuredList = _topRatedBooks.isNotEmpty ? _topRatedBooks.take(6).toList() : _books.take(6).toList();
    if (featuredList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Belum ada buku rekomendasi')),
      );
    }

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: featuredList.length,
        itemBuilder: (context, index) {
          final book = featuredList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildBookCard(book),
          );
        },
      ),
    );
  }

  Widget _buildNewArrivals() {
    if (_isLoading) {
      return const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final list = _filteredBooks;
    if (list.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 28, color: AppColors.outline),
            const SizedBox(height: 6),
            Text(
              'Belum ada buku untuk kategori ini',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final book = list[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildBookCard(book),
          );
        },
      ),
    );
  }

  Widget _buildPopularCollection() {
    if (_isLoading) {
      return const SizedBox(
        height: 230,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final collection = _books.take(8).toList();
    if (collection.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: collection.length,
        itemBuilder: (context, index) {
          final book = collection[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildBookCard(book),
          );
        },
      ),
    );
  }

  Widget _buildBookCard(AdminBookItem book) {
    final formattedPrice = 'Rp ${book.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              bookDetail: BookDetail.fromAdminBookItem(book),
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: AppColors.surfaceContainerLow,
                  child: book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 40,
                                color: AppColors.outline,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 40,
                            color: AppColors.outline,
                          ),
                        ),
                ),
              ),
            ),
            // Book Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedPrice,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (book.rating > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFE59819),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BookstoreBottomNav(
      currentIndex: 0,
      onTabSelected: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryScreen(),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrderListScreen(),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        }
      },
    );
  }
}
