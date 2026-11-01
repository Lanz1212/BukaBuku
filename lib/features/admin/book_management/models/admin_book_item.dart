enum AdminBookStatus {
  menipis,
  tersedia,
  outOfStock,
}

class AdminBookItem {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final int price;
  final int stock;
  final int minStock;
  final String rackCode;
  final String rackLocation;
  final AdminBookStatus status;
  final bool isActive;
  final String category;
  final String coverUrl;
  final String? publisher;
  final int? publishYear;
  final String? description;
  final String format;
  final int pageCount;
  final double rating;
  final int reviewCount;

  const AdminBookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.price,
    required this.stock,
    this.minStock = 5,
    this.rackCode = '',
    required this.rackLocation,
    required this.status,
    required this.isActive,
    required this.category,
    required this.coverUrl,
    this.publisher,
    this.publishYear,
    this.description,
    this.format = 'Softcover',
    this.pageCount = 0,
    this.rating = 4.8,
    this.reviewCount = 0,
  });

  AdminBookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    int? price,
    int? stock,
    int? minStock,
    String? rackCode,
    String? rackLocation,
    AdminBookStatus? status,
    bool? isActive,
    String? category,
    String? coverUrl,
    String? publisher,
    int? publishYear,
    String? description,
    String? format,
    int? pageCount,
    double? rating,
    int? reviewCount,
  }) {
    final updatedStock = stock ?? this.stock;
    final updatedMinStock = minStock ?? this.minStock;

    AdminBookStatus resolvedStatus = status ?? this.status;
    if (status == null && stock != null) {
      if (updatedStock <= 0) {
        resolvedStatus = AdminBookStatus.outOfStock;
      } else if (updatedStock <= updatedMinStock) {
        resolvedStatus = AdminBookStatus.menipis;
      } else {
        resolvedStatus = AdminBookStatus.tersedia;
      }
    }

    return AdminBookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      price: price ?? this.price,
      stock: updatedStock,
      minStock: updatedMinStock,
      rackCode: rackCode ?? this.rackCode,
      rackLocation: rackLocation ?? this.rackLocation,
      status: resolvedStatus,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      coverUrl: coverUrl ?? this.coverUrl,
      publisher: publisher ?? this.publisher,
      publishYear: publishYear ?? this.publishYear,
      description: description ?? this.description,
      format: format ?? this.format,
      pageCount: pageCount ?? this.pageCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  factory AdminBookItem.fromMap(Map<String, dynamic> map) {
    final stockVal = (map['stock'] as num?)?.toInt() ?? 0;
    final minStockVal = (map['min_stock'] as num?)?.toInt() ?? 5;

    AdminBookStatus status;
    if (stockVal <= 0) {
      status = AdminBookStatus.outOfStock;
    } else if (stockVal <= minStockVal) {
      status = AdminBookStatus.menipis;
    } else {
      status = AdminBookStatus.tersedia;
    }

    return AdminBookItem(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      isbn: map['isbn'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      stock: stockVal,
      minStock: minStockVal,
      rackCode: map['rack_code'] as String? ?? '',
      rackLocation: map['rack_location'] as String? ?? '',
      status: status,
      isActive: map['is_active'] as bool? ?? true,
      category: map['category'] as String? ?? 'Umum',
      coverUrl: map['cover_url'] as String? ?? '',
      publisher: map['publisher'] as String?,
      publishYear: (map['publish_year'] as num?)?.toInt(),
      description: map['description'] as String?,
      format: map['format'] as String? ?? 'Softcover',
      pageCount: (map['page_count'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'price': price,
      'stock': stock,
      'min_stock': minStock,
      'rack_code': rackCode,
      'rack_location': rackLocation,
      'is_active': isActive,
      'category': category,
      'cover_url': coverUrl,
      'publisher': publisher,
      'publish_year': publishYear,
      'description': description,
      'format': format,
      'page_count': pageCount,
      'rating': rating,
      'review_count': reviewCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static List<AdminBookItem> get mockBooks => [
        const AdminBookItem(
          id: 'B001',
          title: 'Atomic Habits',
          author: 'James Clear',
          isbn: '978-602-06-3317-6',
          price: 85000,
          stock: 3,
          rackLocation: 'Rak B2 • Bisnis & Self-Help (Lantai 1)',
          status: AdminBookStatus.menipis,
          isActive: true,
          category: 'Pengembangan Diri',
          publisher: 'Gramedia Pustaka Utama',
          publishYear: 2019,
          description:
              'Perubahan kecil yang memberikan hasil luar biasa melalui pembentukan kebiasaan harian secara konsisten.',
          coverUrl:
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
        ),
        const AdminBookItem(
          id: 'B002',
          title: 'Filosofi Teras',
          author: 'Henry Manampiring',
          isbn: '978-602-412-518-9',
          price: 98000,
          stock: 14,
          rackLocation: 'Rak B1 • Filsafat & Psikologi (Lantai 1)',
          status: AdminBookStatus.tersedia,
          isActive: true,
          category: 'Non-Fiksi',
          publisher: 'Penerbit Buku Kompas',
          publishYear: 2018,
          description:
              'Penerapan filsafat Stoisisme kuno untuk mental tangguh di era modern yang penuh tantangan.',
          coverUrl:
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&q=80&w=400',
        ),
      ];
}
