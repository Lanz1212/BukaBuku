import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/book_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/services/review_service.dart';
import '../../../core/utils/auth_dialog_helper.dart';
import '../../../core/utils/app_navigation.dart';
import '../../admin/book_management/models/admin_book_item.dart';
import '../../auth/services/auth_service.dart';
import '../../cart/models/cart_item.dart';
import '../../cart/screens/cart_screen.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../favorite/screens/favorite_screen.dart';
import '../../review/screens/all_reviews_screen.dart';
import '../../review/screens/write_review_screen.dart';
import '../../search/models/book_search_item.dart';
import '../models/book_detail.dart';
import '../widgets/book_cover_section.dart';
import '../widgets/book_description.dart';
import '../widgets/book_detail_bottom_bar.dart';
import '../widgets/book_detail_top_bar.dart';
import '../widgets/book_price_header.dart';
import '../widgets/book_specs_grid.dart';
import '../widgets/guarantee_badge.dart';
import '../widgets/reader_reviews_section.dart';

/// Screen for displaying full book details in Toko Buku Budi
/// Connected with real Supabase database for Cart and Favorites.
class BookDetailScreen extends StatefulWidget {
  final BookDetail? bookDetail;
  final BookSearchItem? searchItem;

  const BookDetailScreen({
    super.key,
    this.bookDetail,
    this.searchItem,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late BookDetail _book;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isActionLoading = false;

  List<BookReview> _realReviews = [];
  bool _canWriteReview = false;
  String? _eligibleOrderId;
  BookReview? _userExistingReview;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    if (widget.bookDetail != null) {
      _book = widget.bookDetail!;
    } else if (widget.searchItem != null) {
      _book = BookDetail.fromSearchItem(widget.searchItem!);
    } else {
      _book = BookDetail.atomicHabitsSample;
    }

    _loadRealBookDetails();
    _checkFavoriteStatus();
  }

  Future<void> _loadRealBookDetails() async {
    if (_book.id.isEmpty) return;
    try {
      final results = await Future.wait([
        BookService.fetchBookById(_book.id),
        ReviewService.fetchBookReviews(_book.id),
        ReviewService.checkPurchaseEligibility(_book.id),
        ReviewService.fetchUserReviewForBook(_book.id),
        ReviewService.getEffectiveUserId(),
      ]);

      if (!mounted) return;

      final dbBook = results[0] as AdminBookItem?;
      final reviews = results[1] as List<BookReview>;
      final eligibility = results[2] as Map<String, dynamic>;
      final userReview = results[3] as BookReview?;
      final uid = results[4] as String?;

      setState(() {
        if (dbBook != null) {
          _book = BookDetail.fromAdminBookItem(dbBook);
        }
        _realReviews = reviews;
        _canWriteReview = eligibility['hasPurchased'] == true;
        _eligibleOrderId = eligibility['orderId'] as String?;
        _userExistingReview = userReview;
        _currentUserId = uid;
      });
    } catch (_) {}
  }

  Future<void> _checkFavoriteStatus() async {
    if (!AuthService.isLoggedIn || _book.id.isEmpty) return;
    try {
      final isFav = await FavoriteService.isFavorite(_book.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    } catch (_) {}
  }

  void _showNotification(String message, {bool isSuccess = true, SnackBarAction? action}) {
    AppNavigation.hideCurrentSnackBar();
    AppNavigation.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.primaryContainer : AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _handleFavoriteToggle() async {
    if (!AuthService.isLoggedIn) {
      final loggedIn = await AuthDialogHelper.showLoginRequiredDialog(
        context,
        title: 'Masuk ke Akun',
        message: 'Silakan masuk agar buku favorit Anda tersimpan di akun pribadi Anda.',
      );
      if (loggedIn == true) {
        _checkFavoriteStatus();
      }
      return;
    }

    try {
      final newStatus = await FavoriteService.toggleFavorite(_book.id);
      if (mounted) {
        setState(() {
          _isFavorite = newStatus;
        });
      }

      _showNotification(
        newStatus
            ? 'Buku disimpan ke daftar favorit'
            : 'Buku dihapus dari daftar favorit',
        action: newStatus
            ? SnackBarAction(
                label: 'LIHAT',
                textColor: AppColors.secondaryFixed,
                onPressed: () {
                  AppNavigation.hideCurrentSnackBar();
                  AppNavigation.push(
                    MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                    ),
                  )?.then((_) => _checkFavoriteStatus());
                },
              )
            : null,
      );
    } catch (e) {
      _showNotification('Gagal memperbarui status favorit: $e', isSuccess: false);
    }
  }

  Future<void> _handleAddToCart() async {
    if (!AuthService.isLoggedIn) {
      final loggedIn = await AuthDialogHelper.showLoginRequiredDialog(
        context,
        title: 'Masuk ke Akun',
        message: 'Silakan masuk agar keranjang belanja Anda tersimpan di akun pribadi Anda.',
      );
      if (loggedIn == true) {
        _handleAddToCart();
      }
      return;
    }

    setState(() => _isActionLoading = true);
    try {
      await CartService.addToCart(_book.id, quantity: _quantity);
      _showNotification(
        '$_quantity x ${_book.title} ditambahkan ke Keranjang',
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
      );
    } catch (e) {
      _showNotification('Gagal memasukkan ke keranjang: $e', isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _handleBuyNow() async {
    if (!AuthService.isLoggedIn) {
      final loggedIn = await AuthDialogHelper.showLoginRequiredDialog(
        context,
        title: 'Masuk ke Akun',
        message: 'Silakan masuk terlebih dahulu untuk melanjutkan pembelian.',
      );
      if (loggedIn == true) {
        _handleBuyNow();
      }
      return;
    }

    // Add to cart directly and proceed to checkout
    try {
      await CartService.addToCart(_book.id, quantity: _quantity);
    } catch (_) {}

    final checkoutItem = CartItem(
      id: 'item-${_book.id}',
      bookId: _book.id,
      title: _book.title,
      author: _book.author,
      formatEdition: _book.format,
      price: _book.price,
      priceValue: _book.priceValue,
      coverUrl: _book.coverUrl,
      storeLocation: _book.storeLocation,
      quantity: _quantity,
      isSelected: true,
    );

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          checkoutItems: [checkoutItem],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookDetailTopBar(
        isFavorite: _isFavorite,
        onFavoriteToggle: _handleFavoriteToggle,
        onSharePressed: () {
          _showNotification('Tautan buku disalin ke clipboard');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Cover Hero
            BookCoverSection(book: _book),

            // Guarantee Badge
            const GuaranteeBadge(),

            const SizedBox(height: 16),

            // Title, Author, Rating, Price, Stock Pill
            BookPriceHeader(book: _book),

            const SizedBox(height: 24),

            // Main Content Sections with standard 16px gutter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spesifikasi Buku
                  BookSpecsGrid(book: _book),

                  const SizedBox(height: 24),

                  // Deskripsi Buku
                  BookDescription(description: _book.description),

                  const SizedBox(height: 24),

                  // Ulasan Pembaca (Data Real dari Database)
                  ReaderReviewsSection(
                    reviews: _realReviews,
                    canWriteReview: _canWriteReview,
                    hasReviewed: _userExistingReview != null,
                    currentUserId: _currentUserId,
                    onSeeAllPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllReviewsScreen(
                            bookId: _book.id,
                            bookTitle: _book.title,
                            currentRating: _book.rating,
                            totalReviews: _book.reviewCount,
                          ),
                        ),
                      ).then((_) => _loadRealBookDetails());
                    },
                    onWriteReviewPressed: () async {
                      final orderId = _eligibleOrderId ??
                          _userExistingReview?.orderId ??
                          'ORD';
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WriteReviewScreen(
                            bookId: _book.id,
                            bookTitle: _book.title,
                            bookAuthor: _book.author,
                            bookCoverUrl: _book.coverUrl,
                            orderId: orderId,
                            initialReview: _userExistingReview,
                          ),
                        ),
                      );
                      if (updated == true) {
                        _loadRealBookDetails();
                      }
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BookDetailBottomBar(
        quantity: _quantity,
        unitPrice: _book.priceValue,
        stockStatus: _book.stockStatus,
        onQuantityChanged: (newQuantity) {
          setState(() {
            _quantity = newQuantity;
          });
        },
        onAddToCart: _isActionLoading ? null : _handleAddToCart,
        onBuyNow: _isActionLoading ? null : _handleBuyNow,
        onNotifyMe: () {
          _showNotification(
            'Pengingat aktif! Kami akan mengirim notifikasi saat stok tersedia.',
          );
        },
      ),
    );
  }
}
