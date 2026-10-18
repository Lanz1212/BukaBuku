import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../category/screens/category_screen.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../models/cart_item.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_reading_note.dart';

enum CartViewMode {
  cartList,
  emptyState,
}

/// Main Shopping Cart Screen for Toko Buku Budi
/// Follows DESIGN.md, AppColors, AppTypography, and Stitch Toko Buku Budi Mobile UI.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = List.from(CartItem.defaultCartItems);
  CartViewMode _viewMode = CartViewMode.cartList;

  bool get _isAllSelected =>
      _items.isNotEmpty && _items.every((item) => item.isSelected);

  int get _selectedCount =>
      _items.where((item) => item.isSelected).fold(0, (sum, item) => sum + item.quantity);

  int get _totalPriceValue => _items
      .where((item) => item.isSelected)
      .fold(0, (sum, item) => sum + (item.priceValue * item.quantity));

  void _toggleSelectAll(bool? selectAll) {
    final value = selectAll ?? !_isAllSelected;
    setState(() {
      _items = _items.map((item) => item.copyWith(isSelected: value)).toList();
    });
  }

  void _toggleItemSelection(int index, bool selected) {
    setState(() {
      _items[index] = _items[index].copyWith(isSelected: selected);
    });
  }

  void _updateQuantity(int index, int newQty) {
    if (newQty < 1) return;
    setState(() {
      _items[index] = _items[index].copyWith(quantity: newQty);
    });
  }

  void _removeItem(int index) {
    final removed = _items[index];
    setState(() {
      _items.removeAt(index);
      if (_items.isEmpty) {
        _viewMode = CartViewMode.emptyState;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.title} dihapus dari keranjang.'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: AppColors.secondaryFixed,
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
              _viewMode = CartViewMode.cartList;
            });
          },
        ),
      ),
    );
  }

  void _clearAllItems() {
    setState(() {
      _items.clear();
      _viewMode = CartViewMode.emptyState;
    });
  }

  void _resetDefaultCart() {
    setState(() {
      _items = List.from(CartItem.defaultCartItems);
      _viewMode = CartViewMode.cartList;
    });
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
    );
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
              'Buku di keranjang disimpan otomatis. Anda dapat memilih buku tertentu sebelum melanjutkan ke halaman pembayaran atau memilih opsi Ambil di Toko Cikini untuk bebas biaya kirim.',
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
    final showCartContent =
        _viewMode == CartViewMode.cartList && _items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Keranjang',
        showHelpButton: true,
        onHelpPressed: _showHelpDialog,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                            '${_items.length} buku siap diproses ke pesanan',
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

                    // 2. Interactive State Demo Switcher Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStateTab(
                              title: 'Daftar Keranjang (${_items.length})',
                              icon: Icons.shopping_bag_outlined,
                              isActive: _viewMode == CartViewMode.cartList,
                              onTap: () {
                                if (_items.isEmpty) {
                                  _resetDefaultCart();
                                } else {
                                  setState(() {
                                    _viewMode = CartViewMode.cartList;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildStateTab(
                              title: 'Lihat Empty State',
                              icon: Icons.bookmark_remove_outlined,
                              isActive: _viewMode == CartViewMode.emptyState,
                              onTap: () {
                                setState(() {
                                  _viewMode = CartViewMode.emptyState;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Conditional Content: Active Cart vs Empty State
                    if (showCartContent) ...[
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
                        onStartShopping: _resetDefaultCart,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // 4. Sticky Checkout Bar (Only shown in active cart list)
            if (showCartContent)
              CartBottomBar(
                selectedCount: _selectedCount,
                totalPriceValue: _totalPriceValue,
                onCheckout: _navigateToCheckout,
              ),

            // 5. Main App Bottom Navigation Bar
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
                } else if (index != 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fitur tab ${index == 3 ? "Pesanan" : "Profil"} segera hadir!',
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
          ],
        ),
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
              size: 16,
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
