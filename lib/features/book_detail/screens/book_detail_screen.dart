import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
import '../widgets/stock_simulator_banner.dart';
import '../../favorite/screens/favorite_screen.dart';

/// Screen for displaying full book details in Toko Buku Budi
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
  }

  void _onStockStatusChanged(StockStatus newStatus) {
    setState(() {
      String label;
      int stock;
      switch (newStatus) {
        case StockStatus.inStock:
          label = 'Stok Tersedia';
          stock = 14;
          break;
        case StockStatus.limited:
          label = 'Sisa 2 Buku';
          stock = 2;
          break;
        case StockStatus.outOfStock:
          label = 'Stok Habis';
          stock = 0;
          break;
      }
      _book = _book.copyWith(
        stockStatus: newStatus,
        stockLabel: label,
        remainingStock: stock,
      );
    });
  }

  void _showNotification(String message, {bool isSuccess = true, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookDetailTopBar(
        isFavorite: _isFavorite,
        onFavoriteToggle: () {
          setState(() {
            _isFavorite = !_isFavorite;
          });
          _showNotification(
            _isFavorite
                ? 'Buku disimpan ke daftar favorit'
                : 'Buku dihapus dari daftar favorit',
            action: _isFavorite
                ? SnackBarAction(
                    label: 'LIHAT',
                    textColor: AppColors.secondaryFixed,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoriteScreen(),
                        ),
                      );
                    },
                  )
                : null,
          );
        },
        onSharePressed: () {
          _showNotification('Tautan buku disalin ke clipboard');
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Stock Simulator Banner for easy preview
            StockSimulatorBanner(
              currentStatus: _book.stockStatus,
              onStatusChanged: _onStockStatusChanged,
            ),

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

                  // Ulasan Pembaca
                  ReaderReviewsSection(
                    reviews: _book.reviews,
                    onSeeAllPressed: () {
                      _showNotification('Membuka seluruh ulasan pembaca...');
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
        onAddToCart: () {
          _showNotification(
            '$_quantity x ${_book.title} ditambahkan ke Keranjang',
          );
        },
        onBuyNow: () {
          _showNotification(
            'Melanjutkan ke checkout untuk $_quantity buku...',
          );
        },
        onNotifyMe: () {
          _showNotification(
            'Pengingat aktif! Kami akan mengirim notifikasi saat stok tersedia.',
          );
        },
      ),
    );
  }
}
