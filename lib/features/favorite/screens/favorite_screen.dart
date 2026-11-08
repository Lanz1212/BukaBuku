import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/auth_dialog_helper.dart';
import '../../../core/utils/app_navigation.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../auth/services/auth_service.dart';
import '../../category/screens/category_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../book_detail/screens/book_detail_screen.dart';
import '../models/favorite_item.dart';
import '../widgets/favorite_item_card.dart';
import '../widgets/favorite_empty_state.dart';
import '../widgets/favorite_promo_note.dart';

/// Main Buku Favorit screen for Toko Buku Budi.
/// Realtime isolated per-user Supabase database integration.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<FavoriteItem> _items = [];
  bool _isLoading = true;

  int get _favoriteCount => _items.length;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _items = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final items = await FavoriteService.fetchFavorites();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeFavorite(int index) async {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });

    bool isUndone = false;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('"${removed.title}" dihapus dari favorit'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'BATAL',
              textColor: AppColors.secondaryFixed,
              onPressed: () {
                isUndone = true;
                setState(() {
                  _items.insert(index, removed);
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) async {
      if (!isUndone) {
        try {
          await FavoriteService.removeFavorite(removed.id);
        } catch (_) {}
      }
    });
  }

  void _addToCart(FavoriteItem item) async {
    if (!AuthService.isLoggedIn) {
      final proceed = await AuthDialogHelper.showLoginRequiredDialog(
        context,
        title: 'Masuk ke Akun',
        message: 'Silakan masuk agar buku dapat dimasukkan ke keranjang belanja pribadi Anda.',
      );
      if (proceed == true) {
        _loadFavorites();
      }
      return;
    }

    try {
      await CartService.addToCart(item.bookId.isNotEmpty ? item.bookId : item.id, quantity: 1);

      if (!mounted) return;
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
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'KERANJANG',
            textColor: AppColors.secondaryFixed,
            onPressed: () {
              AppNavigation.hideCurrentSnackBar();
              AppNavigation.push(
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan ke keranjang: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;
    final showFavoriteContent = isLoggedIn && _items.isNotEmpty;

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: AppColors.surfaceContainerLowest,
          onRefresh: _loadFavorites,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary,
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                      // 2. Unauthenticated Banner if not logged in
                      if (!isLoggedIn) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.bookmark_border_rounded,
                                size: 48,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Masuk untuk Melihat Buku Favorit',
                                style: AppTypography.titleMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Daftar buku favorit tersimpan khusus di akun Anda agar tidak tertukar dengan pembaca lain.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  AuthDialogHelper.showLoginRequiredDialog(
                                    context,
                                    title: 'Masuk ke Akun',
                                    message: 'Masuk sekarang agar Anda bisa menyimpan dan melihat daftar buku favorit.',
                                  ).then((_) => _loadFavorites());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryContainer,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Masuk Sekarang'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else if (showFavoriteContent) ...[
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
                                ).then((_) => _loadFavorites());
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SearchScreen(),
                              ),
                            ).then((_) => _loadFavorites());
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: BookstoreBottomNav(
        currentIndex: 0,
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
          } else if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
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
              const Icon(
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
}
