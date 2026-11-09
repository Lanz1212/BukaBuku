import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_notification_service.dart';
import '../../features/admin/book_management/models/admin_book_item.dart';
import '../../features/admin/stock_management/models/admin_stock_item.dart';
import '../../features/admin/category_management/models/admin_category_item.dart';

class BookService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── READ: Get List of Books ───────────────────────────────────────────────
  static Future<List<AdminBookItem>> fetchBooks({
    String? category,
    String? query,
    bool? onlyActive,
    int? limit,
  }) async {
    var queryBuilder = _client.from('books').select();

    if (category != null && category.isNotEmpty && category != 'Semua') {
      queryBuilder = queryBuilder.eq('category', category);
    }

    if (onlyActive == true) {
      queryBuilder = queryBuilder.eq('is_active', true);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      queryBuilder = queryBuilder.or(
        'title.ilike.%$q%,author.ilike.%$q%,isbn.ilike.%$q%,rack_code.ilike.%$q%',
      );
    }

    final response = await queryBuilder
        .order('created_at', ascending: false)
        .limit(limit ?? 100);

    return (response as List<dynamic>)
        .map((e) => AdminBookItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ─── READ: Top Rated Books (for Rekomendasi / Terpopuler) ─────────────────
  static Future<List<AdminBookItem>> fetchTopRatedBooks({int limit = 8}) async {
    try {
      final response = await _client
          .from('books')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((e) => AdminBookItem.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── READ: Distinct Authors ────────────────────────────────────────────────
  static Future<List<String>> fetchDistinctAuthors({int limit = 8}) async {
    try {
      final response = await _client
          .from('books')
          .select('author')
          .eq('is_active', true)
          .order('author', ascending: true);

      final authors = (response as List<dynamic>)
          .map((e) => (e['author'] as String?)?.trim() ?? '')
          .where((a) => a.isNotEmpty)
          .toSet()
          .take(limit)
          .toList();
      return authors;
    } catch (_) {
      return [];
    }
  }

  // ─── READ: Single Book by ID ───────────────────────────────────────────────
  static Future<AdminBookItem?> fetchBookById(String id) async {
    final response = await _client
        .from('books')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return AdminBookItem.fromMap(response);
  }

  // ─── CREATE: Add Book ──────────────────────────────────────────────────────
  static Future<AdminBookItem> createBook(AdminBookItem book) async {
    final bookMap = book.toMap();
    // If ID is empty, generate an incremental sequential ID (B001, B002, ..., B013, dst.)
    if (book.id.isEmpty) {
      final rows = await _client.from('books').select('id');
      int maxNum = 0;
      for (final row in rows as List<dynamic>) {
        final id = (row['id'] as String?)?.trim() ?? '';
        final match = RegExp(r'^B(\d+)$', caseSensitive: false).firstMatch(id);
        if (match != null) {
          final num = int.tryParse(match.group(1)!) ?? 0;
          if (num < 10000 && num > maxNum) {
            maxNum = num;
          }
        }
      }
      bookMap['id'] = 'B${(maxNum + 1).toString().padLeft(3, '0')}';
    }

    final response = await _client
        .from('books')
        .insert(bookMap)
        .select()
        .single();

    final createdBook = AdminBookItem.fromMap(response);

    try {
      await AdminNotificationService.broadcastToAdmins(
        type: 'bookAdded',
        category: 'inventory',
        title: 'Buku Baru Ditambahkan 📚',
        body: 'Buku "${createdBook.title}" oleh ${createdBook.author} (Stok: ${createdBook.stock}) telah berhasil didaftarkan ke katalog.',
        refId: createdBook.id,
      );
    } catch (e) {
      debugPrint('Error broadcasting admin notification for new book: $e');
    }

    return createdBook;
  }

  // ─── UPDATE: Update Book Data ──────────────────────────────────────────────
  static Future<AdminBookItem> updateBook(AdminBookItem book) async {
    final bookMap = book.toMap();
    final response = await _client
        .from('books')
        .update(bookMap)
        .eq('id', book.id)
        .select()
        .single();

    final updated = AdminBookItem.fromMap(response);

    try {
      await AdminNotificationService.broadcastToAdmins(
        type: 'bookUpdated',
        category: 'inventory',
        title: 'Data Buku Diperbarui 📝',
        body: 'Informasi buku "${updated.title}" (ID: ${updated.id}) telah diperbarui.',
        refId: updated.id,
      );
    } catch (e) {
      debugPrint('Error broadcasting admin notification for updated book: $e');
    }

    return updated;
  }

  // ─── DELETE: Delete Book ───────────────────────────────────────────────────
  static Future<void> deleteBook(String id) async {
    await _client.from('books').delete().eq('id', id);
  }

  // ─── UPDATE: Toggle Book Active Status ─────────────────────────────────────
  static Future<bool> toggleBookStatus(String id, bool newStatus) async {
    await _client.from('books').update({
      'is_active': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
    return newStatus;
  }

  // ─── UPDATE: Adjust Stock with Audit Log ───────────────────────────────────
  static Future<AdminStockItem> adjustStock({
    required String bookId,
    required int previousStock,
    required int newStock,
    required String type, // 'tambah', 'kurang', 'setTotal'
    String? notes,
  }) async {
    final now = DateTime.now().toIso8601String();

    // 1. Update books table
    final updatedBookData = await _client
        .from('books')
        .update({
          'stock': newStock,
          'updated_at': now,
        })
        .eq('id', bookId)
        .select()
        .single();

    // 2. Insert to stock_logs table
    final changeAmount = (newStock - previousStock).abs();
    try {
      await _client.from('stock_logs').insert({
        'book_id': bookId,
        'previous_stock': previousStock,
        'change_amount': changeAmount,
        'new_stock': newStock,
        'adjustment_type': type,
        'notes': notes ?? '',
        'created_at': now,
      });
    } catch (_) {
      // Continue even if logging fails
    }

    // 3. Broadcast notifikasi stok ke seluruh admin
    try {
      final bookTitle = updatedBookData['title'] as String? ?? 'Buku';
      final minStock = (updatedBookData['min_stock'] as num?)?.toInt() ?? 5;
      final rack = updatedBookData['rack_location'] as String? ?? '';

      if (newStock <= 0) {
        await AdminNotificationService.broadcastToAdmins(
          type: 'outOfStock',
          category: 'stock',
          title: 'Stok Buku Habis! 🚨',
          body: 'Buku "$bookTitle" kini telah habis (0 eksemplar). Segera lakukan restock ke supplier.',
          refId: bookId,
        );
      } else if (newStock <= minStock) {
        await AdminNotificationService.broadcastToAdmins(
          type: 'lowStock',
          category: 'stock',
          title: 'Stok Buku Menipis ⚠️',
          body: 'Buku "$bookTitle" tersisa $newStock eksemplar (batas minimum: $minStock). Lokasi rak: $rack.',
          refId: bookId,
        );
      } else {
        final changeSign = (newStock >= previousStock) ? '+$changeAmount' : '-$changeAmount';
        await AdminNotificationService.broadcastToAdmins(
          type: 'stockAdjusted',
          category: 'stock',
          title: 'Penyesuaian Stok Buku 📦',
          body: 'Stok "$bookTitle" disesuaikan dari $previousStock menjadi $newStock eksemplar ($changeSign).',
          refId: bookId,
        );
      }
    } catch (e) {
      debugPrint('Error broadcasting admin notification for stock adjust: $e');
    }

    return AdminStockItem.fromMap(updatedBookData, lastSyncTime: 'Baru saja');
  }

  // ─── READ: Stock Summary Stats ─────────────────────────────────────────────
  static Future<Map<String, int>> fetchStockSummary() async {
    final response = await _client
        .from('books')
        .select('stock, min_stock');

    final books = response as List<dynamic>;
    int totalTitles = books.length;
    int lowStockCount = 0;
    int outOfStockCount = 0;
    int totalCopies = 0;

    for (final b in books) {
      final stock = (b['stock'] as num?)?.toInt() ?? 0;
      final minStock = (b['min_stock'] as num?)?.toInt() ?? 5;

      totalCopies += stock;
      if (stock <= 0) {
        outOfStockCount++;
      } else if (stock <= minStock) {
        lowStockCount++;
      }
    }

    return {
      'totalTitles': totalTitles,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'totalCopies': totalCopies,
    };
  }

  // ─── READ: Stock Items List ────────────────────────────────────────────────
  static Future<List<AdminStockItem>> fetchStockItems({
    String? query,
    int? filterIndex, // 0: Semua, 1: Menipis, 2: Habis, 3: Tersedia
  }) async {
    final books = await fetchBooks(query: query);
    final items = books.map((b) => AdminStockItem.fromBookItem(b)).toList();

    if (filterIndex == null || filterIndex == 0) {
      return items;
    }

    return items.where((item) {
      if (filterIndex == 1) return item.status == AdminStockStatus.menipis;
      if (filterIndex == 2) return item.status == AdminStockStatus.habis;
      if (filterIndex == 3) return item.status == AdminStockStatus.tersedia;
      return true;
    }).toList();
  }

  // ─── READ: Low Stock Books specifically ───────────────────────────────────
  static Future<List<AdminBookItem>> fetchLowStockBooks({int limit = 5}) async {
    final books = await fetchBooks(limit: 50);
    return books
        .where((b) => b.stock <= b.minStock)
        .take(limit)
        .toList();
  }

  // ─── READ: Categories List ─────────────────────────────────────────────────
  static Future<List<String>> fetchCategoryNames() async {
    try {
      final response = await _client
          .from('categories')
          .select('name')
          .order('id', ascending: true);

      final list = (response as List<dynamic>)
          .map((e) => (e['name'] as String?)?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {}

    return [
      'Novel & Sastra',
      'Komik & Manga',
      'Pengembangan Diri',
      'Bisnis & Finansial',
      'Non-Fiksi',
      'Filsafat & Pemikiran',
      'Sejarah & Budaya',
      'Pendidikan',
      'Buku Anak',
    ];
  }

  // ─── CRUD: Category Management ─────────────────────────────────────────────
  static Future<List<AdminCategoryItem>> fetchCategories() async {
    try {
      final catResponse = await _client
          .from('categories')
          .select()
          .order('id', ascending: true);

      final bookResponse = await _client.from('books').select('category');
      final Map<String, int> bookCounts = {};
      for (final b in bookResponse as List<dynamic>) {
        final catName = (b['category'] as String?)?.trim() ?? '';
        if (catName.isNotEmpty) {
          bookCounts[catName] = (bookCounts[catName] ?? 0) + 1;
        }
      }

      return (catResponse as List<dynamic>).map((e) {
        final map = e as Map<String, dynamic>;
        final name = (map['name'] as String?)?.trim() ?? '';
        return AdminCategoryItem.fromMap(map, bookCount: bookCounts[name] ?? 0);
      }).toList();
    } catch (_) {
      return List.from(AdminCategoryItem.mockCategories);
    }
  }

  static Future<AdminCategoryItem> createCategory(AdminCategoryItem cat) async {
    final map = cat.toMap();
    final response = await _client
        .from('categories')
        .insert(map)
        .select()
        .single();

    final createdCat = AdminCategoryItem.fromMap(response, bookCount: 0);

    try {
      await AdminNotificationService.broadcastToAdmins(
        type: 'categoryAdded',
        category: 'inventory',
        title: 'Kategori Baru Ditambahkan 🏷️',
        body: 'Kategori "${createdCat.name}" (Kode: ${createdCat.code}) telah ditambahkan di Lantai ${createdCat.floor}.',
        refId: createdCat.id,
      );
    } catch (e) {
      debugPrint('Error broadcasting admin notification for category added: $e');
    }

    return createdCat;
  }

  static Future<AdminCategoryItem> updateCategory(AdminCategoryItem cat) async {
    final map = cat.toMap();
    final idInt = int.tryParse(cat.id);
    final query = _client.from('categories').update(map);

    final dynamic response;
    if (idInt != null) {
      response = await query.eq('id', idInt).select().single();
    } else {
      response = await query.eq('id', cat.id).select().single();
    }

    final updatedCat = AdminCategoryItem.fromMap(response, bookCount: cat.bookCount);

    try {
      await AdminNotificationService.broadcastToAdmins(
        type: 'categoryUpdated',
        category: 'inventory',
        title: 'Kategori Diperbarui 🏷️',
        body: 'Kategori "${updatedCat.name}" (Kode: ${updatedCat.code}) telah diperbarui.',
        refId: updatedCat.id,
      );
    } catch (e) {
      debugPrint('Error broadcasting admin notification for category updated: $e');
    }

    return updatedCat;
  }

  static Future<void> deleteCategory(String id) async {
    final idInt = int.tryParse(id);
    if (idInt != null) {
      await _client.from('categories').delete().eq('id', idInt);
    } else {
      await _client.from('categories').delete().eq('id', id);
    }
  }
}

