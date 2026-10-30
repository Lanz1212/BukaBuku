import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum AdminStockStatus {
  tersedia,
  menipis,
  habis,
}

class AdminStockItem {
  final String bookId;
  final String title;
  final String author;
  final String isbn;
  final String rackCode;
  final String rackLocation;
  final String coverUrl;
  final int currentStock;
  final int minStock;
  final int price;
  final String lastSyncTime;
  final AdminStockStatus status;

  const AdminStockItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.isbn,
    required this.rackCode,
    required this.rackLocation,
    required this.coverUrl,
    required this.currentStock,
    required this.minStock,
    required this.price,
    required this.lastSyncTime,
    required this.status,
  });

  AdminStockItem copyWith({
    String? bookId,
    String? title,
    String? author,
    String? isbn,
    String? rackCode,
    String? rackLocation,
    String? coverUrl,
    int? currentStock,
    int? minStock,
    int? price,
    String? lastSyncTime,
    AdminStockStatus? status,
  }) {
    final updatedStock = currentStock ?? this.currentStock;
    final updatedMinStock = minStock ?? this.minStock;
    
    // Auto calculate status if not explicitly passed
    AdminStockStatus calculatedStatus = status ?? this.status;
    if (status == null && currentStock != null) {
      if (updatedStock <= 0) {
        calculatedStatus = AdminStockStatus.habis;
      } else if (updatedStock <= updatedMinStock) {
        calculatedStatus = AdminStockStatus.menipis;
      } else {
        calculatedStatus = AdminStockStatus.tersedia;
      }
    }

    return AdminStockItem(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      rackCode: rackCode ?? this.rackCode,
      rackLocation: rackLocation ?? this.rackLocation,
      coverUrl: coverUrl ?? this.coverUrl,
      currentStock: updatedStock,
      minStock: updatedMinStock,
      price: price ?? this.price,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      status: calculatedStatus,
    );
  }

  String get statusLabel {
    switch (status) {
      case AdminStockStatus.tersedia:
        return 'Tersedia';
      case AdminStockStatus.menipis:
        return 'Stok Menipis';
      case AdminStockStatus.habis:
        return 'Habis';
    }
  }

  Color get statusColor {
    switch (status) {
      case AdminStockStatus.tersedia:
        return AppColors.success;
      case AdminStockStatus.menipis:
        return AppColors.warning;
      case AdminStockStatus.habis:
        return AppColors.error;
    }
  }

  Color get statusBackgroundColor {
    switch (status) {
      case AdminStockStatus.tersedia:
        return AppColors.success.withValues(alpha: 0.12);
      case AdminStockStatus.menipis:
        return AppColors.warning.withValues(alpha: 0.12);
      case AdminStockStatus.habis:
        return AppColors.error.withValues(alpha: 0.12);
    }
  }

  static List<AdminStockItem> get mockItems => [
        const AdminStockItem(
          bookId: 'stk-001',
          title: 'Atomic Habits',
          author: 'James Clear',
          isbn: '978-602-06-3317-6',
          rackCode: 'Rak B2',
          rackLocation: 'Rak B2 • Bisnis & Self-Help (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80',
          currentStock: 14,
          minStock: 5,
          price: 108000,
          lastSyncTime: 'Baru saja',
          status: AdminStockStatus.tersedia,
        ),
        const AdminStockItem(
          bookId: 'stk-002',
          title: 'Filosofi Teras',
          author: 'Henry Manampiring',
          isbn: '978-602-412-518-9',
          rackCode: 'Rak B1',
          rackLocation: 'Rak B1 • Filsafat & Psikologi (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&auto=format&fit=crop&q=80',
          currentStock: 3,
          minStock: 5,
          price: 98000,
          lastSyncTime: '10 mnt lalu',
          status: AdminStockStatus.menipis,
        ),
        const AdminStockItem(
          bookId: 'stk-003',
          title: 'Bumi Manusia',
          author: 'Pramoedya Ananta Toer',
          isbn: '978-979-97312-3-4',
          rackCode: 'Rak A3',
          rackLocation: 'Rak A3 • Sastra & Fiksi Sejarah (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400&auto=format&fit=crop&q=80',
          currentStock: 0,
          minStock: 4,
          price: 125000,
          lastSyncTime: '30 mnt lalu',
          status: AdminStockStatus.habis,
        ),
        const AdminStockItem(
          bookId: 'stk-004',
          title: 'Laut Bercerita',
          author: 'Leila S. Chudori',
          isbn: '978-602-424-694-5',
          rackCode: 'Rak A1',
          rackLocation: 'Rak A1 • Novel Best Seller (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&auto=format&fit=crop&q=80',
          currentStock: 22,
          minStock: 6,
          price: 110000,
          lastSyncTime: '1 jam lalu',
          status: AdminStockStatus.tersedia,
        ),
        const AdminStockItem(
          bookId: 'stk-005',
          title: 'Psychology of Money',
          author: 'Morgan Housel',
          isbn: '978-602-06-4882-8',
          rackCode: 'Rak B3',
          rackLocation: 'Rak B3 • Keuangan & Investasi (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1592496431122-2349e0fbc666?w=400&auto=format&fit=crop&q=80',
          currentStock: 2,
          minStock: 5,
          price: 95000,
          lastSyncTime: '2 jam lalu',
          status: AdminStockStatus.menipis,
        ),
        const AdminStockItem(
          bookId: 'stk-006',
          title: 'Sapiens: Riwayat Singkat Umat Manusia',
          author: 'Yuval Noah Harari',
          isbn: '978-602-424-416-3',
          rackCode: 'Rak C2',
          rackLocation: 'Rak C2 • Sejarah Dunia (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&auto=format&fit=crop&q=80',
          currentStock: 8,
          minStock: 4,
          price: 135000,
          lastSyncTime: '3 jam lalu',
          status: AdminStockStatus.tersedia,
        ),
        const AdminStockItem(
          bookId: 'stk-007',
          title: 'Clean Code: Panduan Refactoring',
          author: 'Robert C. Martin',
          isbn: '978-0-13-235088-4',
          rackCode: 'Rak D1',
          rackLocation: 'Rak D1 • Teknologi & Coding (Lantai 2)',
          coverUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&auto=format&fit=crop&q=80',
          currentStock: 0,
          minStock: 3,
          price: 180000,
          lastSyncTime: '4 jam lalu',
          status: AdminStockStatus.habis,
        ),
      ];
}
