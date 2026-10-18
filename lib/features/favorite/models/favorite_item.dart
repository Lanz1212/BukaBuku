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
  final String id;
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

  BookSearchItem toSearchItem() {
    return BookSearchItem(
      id: id,
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
    FavoriteItem(
      id: 'fav-laut-bercerita',
      title: 'Laut Bercerita',
      author: 'Leila S. Chudori',
      price: 'Rp105.000',
      priceValue: 105000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuArl_SZbFCvl4yFphcoCDIh40OO_pSl4rOrvxYTTXPUGdFtG-1WszL0z0f_76VSNqTzhbo8X3ViLk7WnCPNg4iFOnjrx0c6BAFjhNQCTH9jMQltkpyu-ASpXZcjMzFWO44lYOkVdum_alUb4I3J2qlT_GvJXpKH8E6T9VMYx5yd0PmUwLjhC21oXk5YdTBnog0B7zBCnTm-FMwscI-zzvLFCe9pS6MesRTbsyLvVVxcdjY-nBSmP7_Icg',
      stockStatus: StockStatus.limited,
      stockLabel: 'Sisa 2 Buku',
      badgeType: FavoriteBadgeType.terbatas,
    ),
    FavoriteItem(
      id: 'fav-sapiens',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      price: 'Rp125.000',
      priceValue: 125000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCtEHvCPC6idI5neqWVWe4cU0RU0iEXDMgr6r_VTz3XMbMZ124pRCEXtsPPkx1RDq-jhuib293cdBt-TrJUjvps51oPjKJ3OON-rqCInXYiECj8jW6rU3XkyJj1aHLzsae2sN3fMRLbT8xUW-U9WPpPK2sAZI5IFC31z7u3xUW5S_-y6Vhqy60ZAtru7GmdeiPNqxPgPM9Ir1xRv0U3G9Q6y72yCUgoVw1M63VdlVtW3ctfjV0WOQying',
      stockStatus: StockStatus.outOfStock,
      stockLabel: 'Stok Habis',
      badgeType: FavoriteBadgeType.none,
    ),
  ];
}
