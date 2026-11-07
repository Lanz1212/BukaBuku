import '../../search/models/book_search_item.dart';
import '../../admin/book_management/models/admin_book_item.dart';

/// Single reader review model
class BookReview {
  final String id;
  final String reviewerName;
  final String reviewerInitials;
  final bool isVerified;
  final double rating;
  final String timeAgo;
  final String purchaseLocation;
  final String comment;

  const BookReview({
    required this.id,
    required this.reviewerName,
    required this.reviewerInitials,
    this.isVerified = true,
    required this.rating,
    required this.timeAgo,
    this.purchaseLocation = 'Pembeli Toko Buku Budi',
    required this.comment,
  });
}

/// Comprehensive book detail model matching Stitch Toko Buku Budi design
class BookDetail {
  final String id;
  final String title;
  final String author;
  final String authorPrefix;
  final String publisher;
  final String publishYear;
  final String category;
  final String isbn;
  final String format;
  final int pageCount;
  final String price;
  final int priceValue;
  final double rating;
  final int reviewCount;
  final String reviewCountFormatted;
  final String coverUrl;
  final StockStatus stockStatus;
  final String stockLabel;
  final String storeLocation;
  final int remainingStock;
  final String description;
  final List<BookReview> reviews;

  const BookDetail({
    required this.id,
    required this.title,
    required this.author,
    this.authorPrefix = 'Karya',
    required this.publisher,
    required this.publishYear,
    required this.category,
    required this.isbn,
    required this.format,
    required this.pageCount,
    required this.price,
    required this.priceValue,
    required this.rating,
    required this.reviewCount,
    required this.reviewCountFormatted,
    required this.coverUrl,
    required this.stockStatus,
    required this.stockLabel,
    required this.storeLocation,
    required this.remainingStock,
    required this.description,
    required this.reviews,
  });

  /// Factory helper to build from AdminBookItem (Database Model)
  factory BookDetail.fromAdminBookItem(AdminBookItem book) {
    StockStatus stockStatus;
    String stockLabel;
    if (book.stock <= 0) {
      stockStatus = StockStatus.outOfStock;
      stockLabel = 'Stok Habis';
    } else if (book.stock <= book.minStock) {
      stockStatus = StockStatus.limited;
      stockLabel = 'Sisa ${book.stock} Buku';
    } else {
      stockStatus = StockStatus.inStock;
      stockLabel = 'Stok Tersedia (${book.stock})';
    }

    final priceFormatted = 'Rp ${book.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return BookDetail(
      id: book.id,
      title: book.title,
      author: book.author,
      authorPrefix: 'Karya',
      publisher: book.publisher ?? 'Gramedia Pustaka',
      publishYear: book.publishYear?.toString() ?? '2024',
      category: book.category,
      isbn: book.isbn,
      format: book.format.isNotEmpty ? book.format : 'Softcover • ${book.pageCount} Hal.',
      pageCount: book.pageCount,
      price: priceFormatted,
      priceValue: book.price,
      rating: book.rating,
      reviewCount: book.reviewCount,
      reviewCountFormatted: '${book.reviewCount} ulasan',
      coverUrl: book.coverUrl,
      stockStatus: stockStatus,
      stockLabel: stockLabel,
      storeLocation: book.rackLocation.isNotEmpty ? book.rackLocation : 'Rak Buku Utama',
      remainingStock: book.stock,
      description: book.description ?? 'Deskripsi buku belum tersedia.',
      reviews: const [],
    );
  }

  /// Factory helper to build or fallback from a BookSearchItem
  factory BookDetail.fromSearchItem(BookSearchItem item) {
    return BookDetail(
      id: item.id,
      title: item.title,
      author: item.author,
      authorPrefix: 'Karya',
      publisher: 'Penerbit Toko Budi',
      publishYear: '2024',
      category: item.category,
      isbn: 'Tersedia di Toko',
      format: 'Softcover',
      pageCount: 0,
      price: item.price,
      priceValue: item.priceValue,
      rating: item.rating,
      reviewCount: 0,
      reviewCountFormatted: item.reviewCount,
      coverUrl: item.coverUrl,
      stockStatus: item.stockStatus,
      stockLabel: item.stockLabel,
      storeLocation: item.shelfLocation ?? 'Rak Buku Utama',
      remainingStock: item.stockStatus == StockStatus.inStock ? 10 : (item.stockStatus == StockStatus.limited ? 2 : 0),
      description: 'Deskripsi buku belum tersedia.',
      reviews: const [],
    );
  }

  /// Default sample matching the reference screen exactly
  static const BookDetail atomicHabitsSample = BookDetail(
    id: 'B001',
    title: 'Atomic Habits',
    author: 'James Clear',
    authorPrefix: 'Karya',
    publisher: 'Gramedia Pustaka Utama',
    publishYear: '2019',
    category: 'Pengembangan Diri',
    isbn: '978-602-06-3317-6',
    format: 'Softcover • 356 Hal.',
    pageCount: 356,
    price: 'Rp 85.000',
    priceValue: 85000,
    rating: 4.8,
    reviewCount: 1240,
    reviewCountFormatted: '1.240',
    coverUrl:
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
    stockStatus: StockStatus.inStock,
    stockLabel: 'Stok Tersedia',
    storeLocation: 'Rak B2 • Bisnis & Self-Help (Lantai 1)',
    remainingStock: 4,
    description:
        'Perubahan kecil yang memberikan hasil luar biasa melalui pembentukan kebiasaan harian secara konsisten.',
    reviews: [],
  );

  BookDetail copyWith({
    String? id,
    String? title,
    String? author,
    String? authorPrefix,
    String? publisher,
    String? publishYear,
    String? category,
    String? isbn,
    String? format,
    int? pageCount,
    String? price,
    int? priceValue,
    double? rating,
    int? reviewCount,
    String? reviewCountFormatted,
    String? coverUrl,
    StockStatus? stockStatus,
    String? stockLabel,
    String? storeLocation,
    int? remainingStock,
    String? description,
    List<BookReview>? reviews,
  }) {
    return BookDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      authorPrefix: authorPrefix ?? this.authorPrefix,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      category: category ?? this.category,
      isbn: isbn ?? this.isbn,
      format: format ?? this.format,
      pageCount: pageCount ?? this.pageCount,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviewCountFormatted: reviewCountFormatted ?? this.reviewCountFormatted,
      coverUrl: coverUrl ?? this.coverUrl,
      stockStatus: stockStatus ?? this.stockStatus,
      stockLabel: stockLabel ?? this.stockLabel,
      storeLocation: storeLocation ?? this.storeLocation,
      remainingStock: remainingStock ?? this.remainingStock,
      description: description ?? this.description,
      reviews: reviews ?? this.reviews,
    );
  }
}
