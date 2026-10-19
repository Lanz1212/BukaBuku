import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../category/screens/category_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../book_detail/screens/book_detail_screen.dart';
import '../models/favorite_item.dart';
import '../widgets/favorite_item_card.dart';
import '../widgets/favorite_empty_state.dart';
import '../widgets/favorite_promo_note.dart';

enum FavoriteViewMode {
  favoriteList,
  emptyState,
}

/// Main Buku Favorit screen for Toko Buku Budi.
/// Follows DESIGN.md, AppColors, AppTypography, and Stitch Toko Buku Budi Mobile UI.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteItem> _items = List.from(FavoriteItem.defaultFavoriteItems);
  FavoriteViewMode _viewMode = FavoriteViewMode.favoriteList;

  int get _favoriteCount => _items.length;

  void _removeFavorite(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
      if (_items.isEmpty) {
        _viewMode = FavoriteViewMode.emptyState;
      }
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${removed.title}" dihapus dari favorit'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: AppColors.secondaryFixed,
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
              _viewMode = FavoriteViewMode.favoriteList;
            });
          },
        ),
      ),
    );
  }

  void _addToCart(FavoriteItem item) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondaryFixedDim, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '"${item.title}" dimasukkan ke keranjang',
                style: const TextStyle(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _remindWhenAvailable(FavoriteItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.secondaryFixedDim, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pengingat diset untuk "${item.title}"',
                style: const TextStyle(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _resetDefaultFavorites() {
    setState(() {
      _items = List.from(FavoriteItem.defaultFavoriteItems);
      _viewMode = FavoriteViewMode.favoriteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showFavoriteContent =
        _viewMode == FavoriteViewMode.favoriteList && _items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Buku Favorit',
        showBackButton: true,
        showSearchButton: true,
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        onProfilePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Membuka profil akun pembaca...'),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Header: Title and Badge
              _buildHeader(),
              const SizedBox(height: 6),

              // Subtitle description
              Text(
                'Daftar buku impian yang kamu simpan untuk dibaca nanti.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),

              // 2. Interactive State Demo Switcher Tabs
              _buildStateSwitcher(),
              const SizedBox(height: 16),

              // 3. Conditional Content: Favorite List vs Empty State
              if (showFavoriteContent) ...[
                // Favorite Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return FavoriteItemCard(
                      item: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              searchItem: item.toSearchItem(),
                            ),
                          ),
                        );
                      },
                      onRemoveFavorite: () => _removeFavorite(index),
                      onAddToCart: () => _addToCart(item),
                      onRemind: () => _remindWhenAvailable(item),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Promo note card
                const FavoritePromoNote(),
                const SizedBox(height: 24),
              ] else ...[
                // Empty State View
                FavoriteEmptyState(
                  onStartBrowsing: () {
                    if (_items.isEmpty) {
                      _resetDefaultFavorites();
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BookstoreBottomNav(
        currentIndex: 0, // No dedicated tab for Favorite
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CategoryScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const OrderListScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Fitur tab Profil segera hadir!',
                ),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Buku Favorit',
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_added,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                '$_favoriteCount Buku Disimpan',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStateTab(
              title: 'Daftar Favorit ($_favoriteCount)',
              icon: Icons.menu_book,
              isActive: _viewMode == FavoriteViewMode.favoriteList,
              onTap: () {
                if (_items.isEmpty) {
                  _resetDefaultFavorites();
                } else {
                  setState(() {
                    _viewMode = FavoriteViewMode.favoriteList;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: _buildStateTab(
              title: 'Lihat Empty State',
              icon: Icons.heart_broken,
              isActive: _viewMode == FavoriteViewMode.emptyState,
              onTap: () {
                setState(() {
                  _viewMode = FavoriteViewMode.emptyState;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateTab({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfaceContainerLowest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
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
              icon,
              size: 18,
              color: isActive
                  ? AppColors.primaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  color: isActive
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
