import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../book_management/models/admin_book_item.dart';

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

  factory AdminStockItem.fromBookItem(AdminBookItem book, {String lastSyncTime = 'Baru saja'}) {
    AdminStockStatus status;
    if (book.stock <= 0) {
      status = AdminStockStatus.habis;
    } else if (book.stock <= book.minStock) {
      status = AdminStockStatus.menipis;
    } else {
      status = AdminStockStatus.tersedia;
    }

    final rackCode = book.rackCode.isNotEmpty
        ? book.rackCode
        : (book.rackLocation.contains('•')
            ? book.rackLocation.split('•').first.trim()
            : book.rackLocation);

    return AdminStockItem(
      bookId: book.id,
      title: book.title,
      author: book.author,
      isbn: book.isbn,
      rackCode: rackCode,
      rackLocation: book.rackLocation,
      coverUrl: book.coverUrl,
      currentStock: book.stock,
      minStock: book.minStock,
      price: book.price,
      lastSyncTime: lastSyncTime,
      status: status,
    );
  }

  factory AdminStockItem.fromMap(Map<String, dynamic> map, {String lastSyncTime = 'Baru saja'}) {
    final book = AdminBookItem.fromMap(map);
    return AdminStockItem.fromBookItem(book, lastSyncTime: lastSyncTime);
  }

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
          bookId: 'B001',
          title: 'Atomic Habits',
          author: 'James Clear',
          isbn: '978-602-06-3317-6',
          rackCode: 'Rak B2',
          rackLocation: 'Rak B2 • Bisnis & Self-Help (Lantai 1)',
          coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&auto=format&fit=crop&q=80',
          currentStock: 14,
          minStock: 5,
          price: 85000,
          lastSyncTime: 'Baru saja',
          status: AdminStockStatus.tersedia,
        ),
      ];
}
