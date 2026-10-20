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
  final String rackLocation;
  final AdminBookStatus status;
  final bool isActive;
  final String category;
  final String coverUrl;

  const AdminBookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.price,
    required this.stock,
    required this.rackLocation,
    required this.status,
    required this.isActive,
    required this.category,
    required this.coverUrl,
  });

  AdminBookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    int? price,
    int? stock,
    String? rackLocation,
    AdminBookStatus? status,
    bool? isActive,
    String? category,
    String? coverUrl,
  }) {
    return AdminBookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      rackLocation: rackLocation ?? this.rackLocation,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  static List<AdminBookItem> get mockBooks => [
        const AdminBookItem(
          id: 'B001',
          title: 'Atomic Habits',
          author: 'James Clear',
          isbn: '978-602-06-3317-6',
          price: 85000,
          stock: 3,
          rackLocation: 'G-04',
          status: AdminBookStatus.menipis,
          isActive: true,
          category: 'Pengembangan Diri',
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
          rackLocation: 'E-02',
          status: AdminBookStatus.tersedia,
          isActive: true,
          category: 'Non-Fiksi',
          coverUrl:
              'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&q=80&w=400',
        ),
        const AdminBookItem(
          id: 'B003',
          title: 'Laut Bercerita',
          author: 'Leila S. Chudori',
          isbn: '978-602-424-694-5',
          price: 105000,
          stock: 2,
          rackLocation: 'F-12',
          status: AdminBookStatus.menipis,
          isActive: true,
          category: 'Novel',
          coverUrl:
              'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
        ),
        const AdminBookItem(
          id: 'B004',
          title: 'Sapiens: Riwayat Umat Manusia',
          author: 'Yuval Noah Harari',
          isbn: '978-602-444-180-7',
          price: 125000,
          stock: 0,
          rackLocation: 'C-01',
          status: AdminBookStatus.outOfStock,
          isActive: false,
          category: 'Non-Fiksi',
          coverUrl:
              'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&q=80&w=400',
        ),
        const AdminBookItem(
          id: 'B005',
          title: 'Pulang',
          author: 'Tere Liye',
          isbn: '978-602-082-212-9',
          price: 89000,
          stock: 22,
          rackLocation: 'A-01',
          status: AdminBookStatus.tersedia,
          isActive: true,
          category: 'Novel',
          coverUrl:
              'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&q=80&w=400',
        ),
        const AdminBookItem(
          id: 'B006',
          title: 'Si Anak Singkong',
          author: 'Chairul Tanjung',
          isbn: '978-979-709-650-2',
          price: 75000,
          stock: 8,
          rackLocation: 'D-05',
          status: AdminBookStatus.tersedia,
          isActive: true,
          category: 'Non-Fiksi',
          coverUrl:
              'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?auto=format&fit=crop&q=80&w=400',
        ),
      ];
}
