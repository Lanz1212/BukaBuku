import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_stock_item.dart';
import '../widgets/stock_adjust_modal.dart';
import '../widgets/stock_book_card.dart';
import '../widgets/stock_summary_header.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  late List<AdminStockItem> _items;
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: Semua, 1: Menipis, 2: Habis, 3: Tersedia

  @override
  void initState() {
    super.initState();
    _items = List.from(AdminStockItem.mockItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _lowStockCount =>
      _items.where((i) => i.status == AdminStockStatus.menipis).length;

  int get _outOfStockCount =>
      _items.where((i) => i.status == AdminStockStatus.habis).length;

  List<AdminStockItem> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      // Status filter
      if (_selectedFilterIndex == 1 &&
          item.status != AdminStockStatus.menipis) {
        return false;
      }
      if (_selectedFilterIndex == 2 && item.status != AdminStockStatus.habis) {
        return false;
      }
      if (_selectedFilterIndex == 3 &&
          item.status != AdminStockStatus.tersedia) {
        return false;
      }

      // Search query
      if (query.isNotEmpty) {
        final matchTitle = item.title.toLowerCase().contains(query);
        final matchAuthor = item.author.toLowerCase().contains(query);
        final matchIsbn = item.isbn.toLowerCase().contains(query);
        final matchRack = item.rackCode.toLowerCase().contains(query);
        return matchTitle || matchAuthor || matchIsbn || matchRack;
      }

      return true;
    }).toList();
  }

  void _onOpenAdjustModal(AdminStockItem item) {
    StockAdjustModal.show(
      context: context,
      item: item,
      onSaved: (updatedItem) {
        setState(() {
          final index = _items.indexWhere((i) => i.bookId == updatedItem.bookId);
          if (index != -1) {
            _items[index] = updatedItem;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stok "${updatedItem.title}" diperbarui menjadi ${updatedItem.currentStock} eksemplar',
            ),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _syncStockData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sinkronisasi data stok gerai berhasil diperbarui'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = _filteredItems;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Stok Buku',
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pantau & perbarui ketersediaan fisik buku di rak',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${_items.length} Judul',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Store summary header
          StockSummaryHeader(
            totalBooks: _items.length,
            lowStockCount: _lowStockCount,
            outOfStockCount: _outOfStockCount,
            onSyncTap: _syncStockData,
          ),
          const SizedBox(height: 14),

          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari judul, ISBN, penulis, atau kode rak...',
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.outline,
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(0, 'Semua (${_items.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  1,
                  'Menipis ($_lowStockCount)',
                  highlightColor: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  2,
                  'Habis ($_outOfStockCount)',
                  highlightColor: AppColors.error,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  3,
                  'Tersedia (${_items.length - _lowStockCount - _outOfStockCount})',
                  highlightColor: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items Count Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan ${displayedList.length} buku',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                'Urutkan: Status Stok',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Books List
          if (displayedList.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = displayedList[index];
                return StockBookCard(
                  item: item,
                  onAdjustTap: () => _onOpenAdjustModal(item),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, {Color? highlightColor}) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (highlightColor ?? AppColors.primary)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (highlightColor ?? AppColors.onSurfaceVariant),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tidak ada buku yang sesuai',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah kata kunci pencarian atau filter status stok.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
