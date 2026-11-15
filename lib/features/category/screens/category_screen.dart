import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../../core/services/book_service.dart';
import '../models/book_category.dart';
import '../widgets/category_card.dart';
import '../../search/screens/search_screen.dart';
import '../../home/home_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/services/profile_service.dart';

/// Screen displaying all book categories in Toko Buku Budi
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BookCategory> _allCategories = [];
  List<BookCategory> _filteredCategories = [];
  bool _isLoading = true;
  String? _avatarUrl;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCategories();
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    try {
      final profile = await ProfileService.fetchCurrentUserProfile();
      if (mounted) {
        setState(() => _avatarUrl = profile.avatarUrl);
      }
    } catch (_) {}
  }

  Future<void> _loadCategories() async {
    try {
      final results = await Future.wait([
        BookService.fetchCategoryNames(),
        BookService.fetchBooks(onlyActive: true),
      ]);
      final catNames = results[0] as List<String>;
      final books = results[1] as List<dynamic>;

      final countMap = <String, int>{};
      for (final b in books) {
        final cat = b.category as String;
        countMap[cat] = (countMap[cat] ?? 0) + 1;
      }

      final cats = catNames.map((name) {
        final count = countMap[name] ?? 0;
        return BookCategory(
          id: name.toLowerCase().replaceAll(' ', '-'),
          name: name,
          bookCount: '$count Buku',
          icon: _iconForCategory(name),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allCategories = cats;
          _filteredCategories = _applyFilter(cats, _searchController.text);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allCategories = BookCategory.defaultCategories;
          _filteredCategories = _applyFilter(BookCategory.defaultCategories, _searchController.text);
          _isLoading = false;
        });
      }
    }
  }

  List<BookCategory> _applyFilter(List<BookCategory> list, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((category) => category.name.toLowerCase().contains(q)).toList();
  }

  static IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('novel') || n.contains('sastra')) return Icons.auto_stories_outlined;
    if (n.contains('komik') || n.contains('manga')) return Icons.forum_outlined;
    if (n.contains('pendidikan')) return Icons.school_outlined;
    if (n.contains('teknologi')) return Icons.memory_outlined;
    if (n.contains('bisnis') || n.contains('finansial')) return Icons.trending_up_rounded;
    if (n.contains('psikologi') || n.contains('pengembangan')) return Icons.psychology_outlined;
    if (n.contains('agama') || n.contains('religi') || n.contains('filsafat')) return Icons.account_balance_outlined;
    if (n.contains('anak') || n.contains('dongeng')) return Icons.star_outline_rounded;
    if (n.contains('sejarah') || n.contains('budaya')) return Icons.history_edu_outlined;
    return Icons.menu_book_outlined;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredCategories = _applyFilter(_allCategories, query);
    });
  }

  void _navigateToSearch({String? categoryName, String? query}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          initialCategory: categoryName,
          initialQuery: query ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Kategori',
        avatarUrl: _avatarUrl,
        showSearchButton: true,
        onSearchPressed: () => _navigateToSearch(),
        onProfilePressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
          _loadAvatarUrl();
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header Tag Badge: "Koleksi Terkurasi"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_library_outlined,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Koleksi Terkurasi',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Headline Title
            Text(
              'Kategori Buku',
              style: AppTypography.headlineLg.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 6),

            // Subtitle Description
            Text(
              'Jelajahi lebih dari 10.000+ kurasi judul dari berbagai genre terpercaya',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 18),

            // Search Bar Input
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _navigateToSearch(query: value.trim());
                  }
                },
                style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari genre, topik, atau mata pelajaran...',
                  hintStyle: AppTypography.bodyMd.copyWith(
                    color: AppColors.outline,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.outline,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          color: AppColors.onSurfaceVariant,
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2-Column Categories Grid or Empty State
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredCategories.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                ),
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () {
                      _navigateToSearch(categoryName: category.name);
                    },
                  );
                },
              )
            else
              _buildCategoryEmptyState(),

            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: BookstoreBottomNav(
        currentIndex: 1, // Kategori tab active
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            // Already on Kategori screen
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OrderListScreen()),
            );
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 14),
          Text(
            'Kategori Tidak Ditemukan',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci genre lain atau telusuri kurasi rekomendasi kami.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _searchController.clear();
            },
            child: Text(
              'Reset Pencarian Kategori',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
