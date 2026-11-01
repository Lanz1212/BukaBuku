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

/// Home Page — Toko Buku Budi
/// Design: DESIGN.md | AppColors | AppTypography
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  List<AdminBookItem> _books = [];
  bool _isLoadingBooks = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await BookService.fetchBooks(onlyActive: true);
      if (mounted) {
        setState(() {
          _books = books;
          _isLoadingBooks = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingBooks = false);
      }
    }
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Categories
                    _buildCategories(),
                    const SizedBox(height: 24),

                    // Featured Books
                    _buildSectionTitle('Buku Rekomendasi'),
                    const SizedBox(height: 12),
                    _buildFeaturedBooks(),
                    const SizedBox(height: 24),

                    // New Arrivals
                    _buildSectionTitle('Buku Terbaru'),
                    const SizedBox(height: 12),
                    _buildNewArrivals(),
                    const SizedBox(height: 24),

                    // Promo Banner
                    _buildPromoBanner(),
                    const SizedBox(height: 24),

                    // Popular Authors
                    _buildSectionTitle('Penulis Populer'),
                    const SizedBox(height: 12),
                    _buildPopularAuthors(),
                    const SizedBox(height: 16),
                  ],
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
                        'Toko Buku Budi',
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
    final categories = [
      'Semua',
      'Fiksi',
      'Non-Fiksi',
      'Anak',
      'Komik',
      'Self-Help',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
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
                  categories[index],
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

  Widget _buildSectionTitle(String title) {
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
        Text(
          'Lihat Semua',
          style: AppTypography.labelMd.copyWith(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBooks() {
    if (_isLoadingBooks) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final featuredList = _books.take(6).toList();
    if (featuredList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Belum ada buku rekomendasi')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
    if (_isLoadingBooks) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final newList = _books.reversed.take(6).toList();
    if (newList.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Belum ada buku terbaru')),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: newList.length,
        itemBuilder: (context, index) {
          final book = newList[index];
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
              flex: 3,
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const Spacer(),
                    Text(
                      formattedPrice,
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diskon 20%',
                  style: AppTypography.headlineLg.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk pembelian pertama',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              'Ambil Promo',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularAuthors() {
    final authors = [
      'Andrea Hirata',
      'Pramoedya A. Toer',
      'Tere Liye',
      'Dee Lestari',
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: authors.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authors[index],
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
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
