import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../models/admin_order_detail.dart';
import 'detail_section_card.dart';

class BookListSection extends StatelessWidget {
  final AdminOrderDetail order;

  const BookListSection({
    super.key,
    required this.order,
  });

  String _formatCurrency(int amount) {
    return 'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  Widget _buildBookCoverThumbnail(AdminOrderBookItem book) {
    final titleLower = book.title.toLowerCase();

    // High fidelity custom cover visuals mirroring the screenshot
    if (titleLower.contains('atomic')) {
      return Container(
        width: 48,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFE4DACB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 2,
              width: 20,
              color: const Color(0xFFC0732E),
            ),
            Column(
              children: [
                Text(
                  'Atomic',
                  style: TextStyle(
                    fontFamily: AppTypography.caption.fontFamily,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B2E24),
                    height: 1.1,
                  ),
                ),
                Text(
                  'Habits',
                  style: TextStyle(
                    fontFamily: AppTypography.caption.fontFamily,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B2E24),
                    height: 1.1,
                  ),
                ),
              ],
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD6C1AA), width: 1.5),
              ),
            ),
          ],
        ),
      );
    }

    if (titleLower.contains('filosofi')) {
      return Container(
        width: 48,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF2B2520),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF4A3E35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 2,
              width: 16,
              color: const Color(0xFFD99A35),
            ),
            Column(
              children: [
                Text(
                  'FILOSOFI',
                  style: TextStyle(
                    fontFamily: AppTypography.caption.fontFamily,
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF3ECE0),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'TERAS',
                  style: TextStyle(
                    fontFamily: AppTypography.caption.fontFamily,
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD99A35),
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.auto_stories_rounded,
              size: 10,
              color: Color(0xFFD99A35),
            ),
          ],
        ),
      );
    }

    // Default book cover fallback
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 20,
          color: AppColors.primaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = order.books.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.qty),
    );

    return DetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Item count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daftar Buku Pesanan',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '${order.books.length} Item',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // List of Books
          ...order.books.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            final rack = book.rackLocation ??
                (index == 0 ? 'Rak A-04 (Lantai 1)' : 'Rak B-12 (Lantai 1)');

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < order.books.length - 1 ? 16.0 : 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookCoverThumbnail(book),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          book.author,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Rack Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFE4D6C8),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shelves,
                                size: 11,
                                color: Color(0xFF8C5C33),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rack,
                                style: AppTypography.caption.copyWith(
                                  color: const Color(0xFF8C5C33),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${book.qty}x ${_formatCurrency(book.price)}',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _formatCurrency(book.price * book.qty),
                              style: AppTypography.titleMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFEFECE6)),
          const SizedBox(height: 12),

          // Subtotal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Buku',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              Text(
                _formatCurrency(subtotal),
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Cashier Service Fee Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya Layanan Kasir',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              Text(
                order.cashierFee == 0
                    ? 'Gratis'
                    : _formatCurrency(order.cashierFee),
                style: AppTypography.bodyMd.copyWith(
                  color: const Color(0xFF8C5C33),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Pesanan Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pesanan',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatCurrency(order.totalPrice),
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
