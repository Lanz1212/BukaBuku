import '../../search/models/book_search_item.dart';

/// Badge type shown on the book cover in the favorite list
enum FavoriteBadgeType {
  bestseller,
  edisiBaru,
  terbatas,
  none,
}

/// Model representing a favorite/wishlist book item
/// Matches the Stitch "Buku Favorit" screen specification.
class FavoriteItem {
  final String id; // ID of favorite record in database
  final String bookId; // ID of book in books table
  final String title;
  final String author;
  final String price;
  final int priceValue;
  final String coverUrl;
  final StockStatus stockStatus;
  final String stockLabel;
  final FavoriteBadgeType badgeType;
  final bool isFavorite;

  const FavoriteItem({
    required this.id,
    this.bookId = '',
    required this.title,
    required this.author,
    required this.price,
    required this.priceValue,
    required this.coverUrl,
    required this.stockStatus,
    required this.stockLabel,
    this.badgeType = FavoriteBadgeType.none,
    this.isFavorite = true,
  });

  FavoriteItem copyWith({
    String? id,
    String? bookId,
    String? title,
    String? author,
    String? price,
    int? priceValue,
    String? coverUrl,
    StockStatus? stockStatus,
    String? stockLabel,
    FavoriteBadgeType? badgeType,
    bool? isFavorite,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      coverUrl: coverUrl ?? this.coverUrl,
      stockStatus: stockStatus ?? this.stockStatus,
      stockLabel: stockLabel ?? this.stockLabel,
      badgeType: badgeType ?? this.badgeType,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Factory from Supabase `favorite_items` with joined `books` record
  factory FavoriteItem.fromSupabase(Map<String, dynamic> map) {
    final booksData = map['books'];
    final book = booksData is Map<String, dynamic> ? booksData : <String, dynamic>{};

    final rawPrice = book['price'];
    final priceVal = rawPrice is num ? rawPrice.toInt() : int.tryParse(rawPrice?.toString() ?? '0') ?? 0;
    final formattedPrice = 'Rp${priceVal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';

    final stock = (book['stock'] as num?)?.toInt() ?? 0;
    final minStock = (book['min_stock'] as num?)?.toInt() ?? 5;

    StockStatus stockStatus;
    String stockLabel;
    if (stock <= 0) {
      stockStatus = StockStatus.outOfStock;
      stockLabel = 'Stok Habis';
    } else if (stock <= minStock) {
      stockStatus = StockStatus.limited;
      stockLabel = 'Sisa $stock Buku';
    } else {
      stockStatus = StockStatus.inStock;
      stockLabel = 'Stok Tersedia';
    }

    final bId = map['book_id']?.toString() ?? book['id']?.toString() ?? '';

    return FavoriteItem(
      id: map['id']?.toString() ?? bId,
      bookId: bId,
      title: (book['title'] as String?)?.trim() ?? 'Buku Tanpa Judul',
      author: (book['author'] as String?)?.trim() ?? 'Penulis',
      price: formattedPrice,
      priceValue: priceVal,
      coverUrl: (book['cover_url'] as String?)?.trim() ?? '',
      stockStatus: stockStatus,
      stockLabel: stockLabel,
      badgeType: FavoriteBadgeType.none,
      isFavorite: true,
    );
  }

  BookSearchItem toSearchItem() {
    return BookSearchItem(
      id: bookId.isNotEmpty ? bookId : id,
      title: title,
      author: author,
      category: 'Buku Pilihan',
      rating: 4.8,
      reviewCount: '1.2k',
      price: price,
      priceValue: priceValue,
      coverUrl: coverUrl,
      shelfLocation: 'Rak Utama',
      stockStatus: stockStatus,
      stockLabel: stockLabel,
    );
  }

  /// Default favorite items matching the Stitch "Buku Favorit" screen
  static const List<FavoriteItem> defaultFavoriteItems = [
    FavoriteItem(
      id: 'fav-atomic-habits',
      bookId: 'B001',
      title: 'Atomic Habits',
      author: 'James Clear',
      price: 'Rp85.000',
      priceValue: 85000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCXUrqerF0NmwswSQl8ICZSKoggr4WsE9IxQAyI_Fub2qQjrWzkBTzP_8UH-DonhIpjBQFYIpb0JmGqT79w6cBdgVEIrryh601U1DAfqcTqWcsNJKnDtnuuyPAk0PuNkWmPhcHbyWBeCG_7fuJII0xzrM8uSl0lk9g_qM_Lpqng0S8TvpchnRrNYdMufN2ANM6F9yaKqZQnaU8rVS9BMeiUkoYr7l-aY6fLEEAX9CwPdUlPPgFDUogdFQ',
      stockStatus: StockStatus.inStock,
      stockLabel: 'Stok Tersedia',
      badgeType: FavoriteBadgeType.bestseller,
    ),
    FavoriteItem(
      id: 'fav-filosofi-teras',
      bookId: 'B002',
      title: 'Filosofi Teras',
      author: 'Henry Manampiring',
      price: 'Rp98.000',
      priceValue: 98000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB-09j6-rD042b63WcR0CBq3NA223Md8IqxuvakXuGu0vFvEkJhLu7EmlrcQ2k52J23MzYbBtLddHXcqOQ9qfEmPlV6AwNKKW7cJePp01gsmkReWUy0sUTva9a8M0mtslWF1_YgCrZaLNcfQfpdQlRZxQ3JgUmmi8AzAZkjv7XDM73biMIK_71uQPaAFd3VWY5atBY-FD7FC71lQHKszjX5wv4Y2OuHXjJNEY9DH02dVTckswx7kcFpRw',
      stockStatus: StockStatus.inStock,
      stockLabel: 'Stok Tersedia',
      badgeType: FavoriteBadgeType.edisiBaru,
    ),
  ];
}
