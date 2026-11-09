import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/auth_dialog_helper.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../auth/services/auth_service.dart';
import '../../category/screens/category_screen.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/cart_item.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_reading_note.dart';

/// Main Shopping Cart Screen for Toko Buku Budi
/// Realtime isolated per-user Supabase database integration.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _isLoading = true;
  final Map<String, Timer> _debounceTimers = {};

  bool get _isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  int get _selectedCount =>
      _items.where((item) => item.isSelected).fold(0, (sum, item) => sum + item.quantity);

  int get _totalPriceValue => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.priceValue * item.quantity));

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  Future<void> _loadCart() async {
    if (!AuthService.isLoggedIn) {
      setState(() {
        _items = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      final items = await CartService.fetchCartItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSelectAll(bool? selectAll) async {
    final value = selectAll ?? !_isAllSelected;
    setState(() {
      _items = _items.map((item) => item.copyWith(isSelected: value)).toList();
    });

    try {
      await CartService.updateAllSelection(value);
    } catch (_) {}
  }

  void _toggleItemSelection(int index, bool selected) async {
    final item = _items[index];
    setState(() {
      _items[index] = item.copyWith(isSelected: selected);
    });

    try {
      await CartService.updateSelection(item.id, selected);
    } catch (_) {}
  }

  void _updateQuantity(int index, int newQty) {
    if (newQty < 1) return;
    final item = _items[index];

    // Optimistic UI update
    setState(() {
      _items[index] = item.copyWith(quantity: newQty);
    });

    // Debounce database sync (800ms)
    _debounceTimers[item.id]?.cancel();
    _debounceTimers[item.id] = Timer(const Duration(milliseconds: 800), () async {
      try {
        await CartService.updateQuantity(item.id, newQty);
      } catch (e) {
        debugPrint('Failed to sync cart quantity: $e');
      }
    });
  }

  void _removeItem(int index) async {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });

    bool isUndone = false;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('${removed.title} dihapus dari keranjang.'),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
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
          await CartService.removeCartItem(removed.id);
        } catch (_) {}
      }
    });
  }

  void _clearAllItems() async {
    if (_items.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Apakah Anda yakin ingin menghapus semua buku dari keranjang?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _items.clear();
      });
      try {
        await CartService.clearCart();
      } catch (_) {}
    }
  }

  void _navigateToCheckout() {
    final selectedItems = _items.where((i) => i.isSelected).toList();
    if (selectedItems.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          checkoutItems: selectedItems,
        ),
      ),
    ).then((_) {
      // Refresh cart upon returning from checkout
      _loadCart();
    });
  }

  void _showHelpDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: AppColors.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Bantuan Keranjang Belanja',
                  style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Buku di keranjang disimpan otomatis ke akun Anda. Anda dapat memilih buku tertentu sebelum melanjutkan ke halaman pembayaran atau memilih opsi Ambil di Toko Cikini untuk bebas biaya kirim.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthService.isLoggedIn;
    final showCartContent = isLoggedIn && _items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Keranjang',
        showHelpButton: true,
        onHelpPressed: _showHelpDialog,
        onProfilePressed: () {
          Navigator.of(context).push(
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
          onRefresh: _loadCart,
          child: Column(
            children: [
              Expanded(
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

                            // 1. Context Subheader (Book Count & Store Badge)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    !isLoggedIn
                                        ? 'Masuk ke akun untuk melihat keranjang Anda'
                                        : '${_items.length} buku tersimpan di keranjang',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.secondary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Toko Budi Cikini',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                      Icons.lock_person_outlined,
                                      size: 48,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Akun Belum Masuk',
                                      style: AppTypography.titleMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Keranjang belanja Anda tersimpan secara pribadi di database akun Anda. Silakan masuk untuk melihat dan mengelola buku.',
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
                                          message: 'Silakan masuk agar keranjang belanja Anda tersambung ke database pribadi Anda.',
                                        ).then((_) => _loadCart());
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
                            ] else if (showCartContent) ...[
                              // Select All & Clear Bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleSelectAll(null),
                                      child: Row(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: _isAllSelected
                                                  ? AppColors.primaryContainer
                                                  : AppColors.surfaceContainerLowest,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: _isAllSelected
                                                    ? AppColors.primaryContainer
                                                    : AppColors.outlineVariant,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: _isAllSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Pilih Semua (${_items.length})',
                                            style: AppTypography.titleMd.copyWith(
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _clearAllItems,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_sweep_outlined,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Hapus Semua',
                                              style: AppTypography.labelMd.copyWith(
                                                color: AppColors.error,
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

                              const SizedBox(height: 14),

                              // Cart Items List
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _items[index];
                                  return CartItemCard(
                                    item: item,
                                    onSelectionChanged: (selected) =>
                                        _toggleItemSelection(index, selected),
                                    onQuantityChanged: (qty) =>
                                        _updateQuantity(index, qty),
                                    onDelete: () => _removeItem(index),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Editorial Literary Note Card
                              const CartReadingNote(),

                              const SizedBox(height: 24),
                            ] else ...[
                              // Empty State View
                              CartEmptyState(
                                onStartShopping: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const CategoryScreen(),
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

              // Sticky Checkout Bar (Only shown in active cart list with items)
              if (showCartContent)
                CartBottomBar(
                  selectedCount: _selectedCount,
                  totalPriceValue: _totalPriceValue,
                  onCheckout: _navigateToCheckout,
                ),

              // Main App Bottom Navigation Bar
              BookstoreBottomNav(
                currentIndex: 2,
                onTabSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
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
            ],
          ),
        ),
      ),
    );
  }
}
