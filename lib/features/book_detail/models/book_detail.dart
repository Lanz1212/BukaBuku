import '../../search/models/book_search_item.dart';

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
  final String originalPrice;
  final int originalPriceValue;
  final String discountPercentage;
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
    required this.originalPrice,
    required this.originalPriceValue,
    required this.discountPercentage,
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

  /// Factory helper to build or fallback from a BookSearchItem
  factory BookDetail.fromSearchItem(BookSearchItem item) {
    if (item.id == 'atomic-habits-new' || item.title.toLowerCase().contains('atomic habits')) {
      return atomicHabitsSample;
    }

    return BookDetail(
      id: item.id,
      title: item.title,
      author: item.author,
      authorPrefix: 'Karya',
      publisher: 'Gramedia Pustaka',
      publishYear: '2021',
      category: item.category,
      isbn: '978-602-06-3317-6',
      format: 'Softcover • 356 Hal.',
      pageCount: 356,
      price: item.price,
      priceValue: item.priceValue,
      originalPrice: 'Rp105.000',
      originalPriceValue: 105000,
      discountPercentage: '-19%',
      rating: item.rating,
      reviewCount: 1240,
      reviewCountFormatted: item.reviewCount,
      coverUrl: item.coverUrl,
      stockStatus: item.stockStatus,
      stockLabel: item.stockLabel,
      storeLocation: 'Toko Cikini',
      remainingStock: item.stockStatus == StockStatus.inStock ? 14 : (item.stockStatus == StockStatus.limited ? 2 : 0),
      description:
          'Perubahan nyata tidak berasal dari revolusi besar dalam satu malam, melainkan dari efek kumulatif ratusan keputusan kecil—seperti push-up dua kali sehari, bangun lima menit lebih awal, atau membaca satu halaman buku setiap pagi.\n\nDalam buku ini, James Clear membongkar bagaimana kebiasaan-kebiasaan kecil dapat menghasilkan perubahan besar yang mengubah hidup. Dilengkapi riset ilmiah mutakhir dan strategi praktis yang terbukti berhasil diterapkan ribuan pembaca di seluruh dunia.',
      reviews: const [
        BookReview(
          id: 'rev-1',
          reviewerName: 'Anindya Rahma',
          reviewerInitials: 'AR',
          isVerified: true,
          rating: 5.0,
          timeAgo: '2 hari yang lalu',
          purchaseLocation: 'Pembeli Toko Buku Budi',
          comment:
              'Buku sangat membuka wawasan dan mengubah caraku memandang resolusi tahun baru. Kemasan buku dari Toko Budi sangat rapi dengan bubble wrap tebal dan pembatas buku estetik!',
        ),
      ],
    );
  }

  /// Default sample matching the reference screen exactly
  static const BookDetail atomicHabitsSample = BookDetail(
    id: 'atomic-habits-new',
    title: 'Atomic Habits',
    author: 'James Clear',
    authorPrefix: 'Karya',
    publisher: 'Gramedia Pustaka',
    publishYear: '2019',
    category: 'Self Development',
    isbn: '978 - 602 - 06 - 3317 - 6',
    format: 'Softcover • 356 Hal.',
    pageCount: 356,
    price: 'Rp85.000',
    priceValue: 85000,
    originalPrice: 'Rp105.000',
    originalPriceValue: 105000,
    discountPercentage: '-19%',
    rating: 4.8,
    reviewCount: 1240,
    reviewCountFormatted: '1.240',
    coverUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB6U3tZ1CSsiY38CMBF6ffD0OgiXUbbBeJpnGght2Ai6QVdy10xGbxTxw89-yIaOJ766IipQ3lRYmqC08-l3tffU25FIUvpZ3C81RXElJItxyc4IlDXFGqPcUVaSXwsT8K9B6xiol9NxzFNm3uEosQJ4I9s3q-AqVnbH2a8A7r4Gewk6THB-DQrWOx3bP1aCUJXWBrgj9J6JukRZCtSHA964UKcF1Nn4VUB8PU_4Lh3NOhaRnGq5Th0pw',
    stockStatus: StockStatus.inStock,
    stockLabel: 'Stok Tersedia',
    storeLocation: 'Toko Cikini',
    remainingStock: 14,
    description:
        'Perubahan nyata tidak berasal dari revolusi besar dalam satu malam, melainkan dari efek kumulatif ratusan keputusan kecil—seperti push-up dua kali sehari, bangun lima menit lebih awal, atau membaca satu halaman buku setiap pagi.\n\nDalam buku bestseller nomor 1 New York Times ini, James Clear menyajikan cara praktis dan terbukti untuk membentuk kebiasaan baik, mematahkan kebiasaan buruk, dan menguasai perilaku kecil yang membawa hasil luar biasa.',
    reviews: [
      BookReview(
        id: 'rev-1',
        reviewerName: 'Anindya Rahma',
        reviewerInitials: 'AR',
        isVerified: true,
        rating: 5.0,
        timeAgo: '2 hari yang lalu',
        purchaseLocation: 'Pembeli Toko Buku Budi',
        comment:
            'Buku sangat membuka wawasan dan mengubah caraku memandang resolusi tahun baru. Kemasan buku dari Toko Budi sangat rapi dengan bubble wrap tebal dan pembatas buku estetik!',
      ),
    ],
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
    String? originalPrice,
    int? originalPriceValue,
    String? discountPercentage,
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
      originalPrice: originalPrice ?? this.originalPrice,
      originalPriceValue: originalPriceValue ?? this.originalPriceValue,
      discountPercentage: discountPercentage ?? this.discountPercentage,
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
