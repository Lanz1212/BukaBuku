enum StockStatus {
  inStock,
  limited,
  outOfStock,
}

/// Model representing a book in the search catalog
class BookSearchItem {
  final String id;
  final String title;
  final String author;
  final String price;
  final int priceValue;
  final double rating;
  final String reviewCount;
  final String coverUrl;
  final String? shelfLocation;
  final StockStatus stockStatus;
  final String stockLabel;
  final String category;

  const BookSearchItem({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.priceValue,
    required this.rating,
    required this.reviewCount,
    required this.coverUrl,
    this.shelfLocation,
    required this.stockStatus,
    required this.stockLabel,
    required this.category,
  });

  /// Sample dataset from Stitch Toko Buku Budi
  static const List<BookSearchItem> defaultSearchItems = [
    BookSearchItem(
      id: 'atomic-habits-new',
      title: 'Atomic Habits (Cover Baru)',
      author: 'James Clear',
      price: 'Rp85.000',
      priceValue: 85000,
      rating: 4.8,
      reviewCount: '1.2k',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB6U3tZ1CSsiY38CMBF6ffD0OgiXUbbBeJpnGght2Ai6QVdy10xGbxTxw89-yIaOJ766IipQ3lRYmqC08-l3tffU25FIUvpZ3C81RXElJItxyc4IlDXFGqPcUVaSXwsT8K9B6xiol9NxzFNm3uEosQJ4I9s3q-AqVnbH2a8A7r4Gewk6THB-DQrWOx3bP1aCUJXWBrgj9J6JukRZCtSHA964UKcF1Nn4VUB8PU_4Lh3NOhaRnGq5Th0pw',
      shelfLocation: 'Rak A3 (Utama)',
      stockStatus: StockStatus.inStock,
      stockLabel: 'Stok Tersedia',
      category: 'Self-Help',
    ),
    BookSearchItem(
      id: 'power-of-habit',
      title: 'The Power of Habit',
      author: 'Charles Duhigg',
      price: 'Rp95.000',
      priceValue: 95000,
      rating: 4.7,
      reviewCount: '890',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBz2bsxwjxhwwFGb4nXll9WWhGJkFn0XZFw6iScYD06rZU2LWhplt3QXz-Vfp2JNFhbVBXunSQmQN6gtw3-lIcCF30qard276mKflD7RKURyuOoVrIM2x0Y_gfyaOgNzdo6vj8-k3ntfZMJus9OwFKE9kSg4XZ1si22eAHUCX591gYSmcHzno76b0wTgzaB9_8z1cmpR3OxoULw28aIVNUVKjEt1rChn9Ouj_Yemjb9EbrBAZhtzHrAjg',
      stockStatus: StockStatus.inStock,
      stockLabel: 'Stok Tersedia',
      category: 'Self-Help',
    ),
    BookSearchItem(
      id: 'tiny-habits',
      title: 'Tiny Habits',
      author: 'BJ Fogg',
      price: 'Rp89.000',
      priceValue: 89000,
      rating: 4.6,
      reviewCount: '420',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDG7o4YVX73ykV3CZhkoDd2fNnar0yJ-QmDyg6ReQPMAtKkYWRfU8lUSZOoz8-6gL-gsXYCLKcig-GNkVFaSzgIcWfY5UJlVgOQcWDGUULCsUDbW9eYAMvm0Gi6IQSs6AznjRK_NBf3lQFcYG2jJvqc0Gzw_OHYhvQKvlZWkyT-CXRveFCGFb2RdJDMrBoVSW5Tn9bjboLReXUzSGm4xtpa_zSDne9vC18km4m-9nUJtYYD0V7w8CffTA',
      stockStatus: StockStatus.limited,
      stockLabel: 'Sisa 2 Buku',
      category: 'Self-Help',
    ),
    BookSearchItem(
      id: 'atomic-habits-workbook',
      title: 'Atomic Habits Workbook',
      author: 'James Clear',
      price: 'Rp65.000',
      priceValue: 65000,
      rating: 4.8,
      reviewCount: '310',
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDNvVf-R85jRvbf5E73Pgv5wES-Hw_keatI1pFQpTx-54x_5mQ9ASyV5wd_ssF2erV_Vz-J-N3OV9RkGiZXJEPCY2JigUM_UL8PalhckNDfpcVVH0qAeeGMdtd_NQXfzoAtRX0xltaPPyd2zOfeEBsdUcY8DTAXCqbX5QVg8bdYpE8GQendGcXgPypvor6sTlIzN-Wx9xWvp266B5a8veE3sgd49mudm85kfvAx3eC26-vOlaKwmP9pVw',
      stockStatus: StockStatus.outOfStock,
      stockLabel: 'Stok Habis',
      category: 'Self-Help',
    ),
  ];
}
