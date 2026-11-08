import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_order_detail.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final AdminOrderDetail order;
  final VoidCallback onDetailTap;
  final VoidCallback onActionTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onDetailTap,
    required this.onActionTap,
  });

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.status == AdminOrderStatus.baru
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Order ID, Time, & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#${order.orderId}',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•  ${order.orderTime}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              OrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 10),

          // Customer Info Row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  order.customerInitials,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      order.customerPhone,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Call / WhatsApp shortcut icon
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menghubungi ${order.customerName} (${order.customerPhone})'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.phone_outlined, size: 18),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
                tooltip: 'Hubungi Pembeli',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Delivery Method & Payment Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  order.deliveryType.contains('Pickup')
                      ? Icons.storefront_rounded
                      : Icons.local_shipping_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.deliveryType,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: order.isPaid
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.paymentMethod,
                    style: AppTypography.caption.copyWith(
                      color: order.isPaid ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Books Items Summary
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.books.map(
                  (book) => Padding(
                    padding: const EdgeInsets.only(bottom: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${book.qty}x  ${book.title}',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatCurrency(book.price * book.qty),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(height: 1, color: AppColors.outlineVariant),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Belanja (${order.books.length} judul)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                    Text(
                      _formatCurrency(order.totalPrice),
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Special Note (if any)
          if (order.specialNote != null && order.specialNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.specialNote!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Actions Row
          Row(
            children: [
              // Detail button
              OutlinedButton(
                onPressed: onDetailTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Detail',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Contextual Action Button
              Expanded(
                child: _buildContextualActionButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextualActionButton() {
    switch (order.status) {
      case AdminOrderStatus.baru:
        return ElevatedButton.icon(
          onPressed: onActionTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
          label: Text(
            'Proses Pesanan',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.diproses:
        final isDelivery = order.deliveryType.toLowerCase().contains('kurir');
        return ElevatedButton.icon(
          onPressed: onActionTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDelivery ? const Color(0xFF8E44AD) : AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(isDelivery ? Icons.inventory_2_outlined : Icons.task_alt_rounded, size: 16),
          label: Text(
            isDelivery ? 'Paket Siap Dikirim' : 'Tandai Siap',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.siapDikirim:
        return ElevatedButton.icon(
          onPressed: onActionTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.two_wheeler_rounded, size: 16),
          label: Text(
            'Serahkan ke Kurir',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.siapDiambil:
        return ElevatedButton.icon(
          onPressed: onActionTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
          label: Text(
            'Scan QR Pickup',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.dalamPengiriman:
        return OutlinedButton.icon(
          onPressed: onActionTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: const BorderSide(color: AppColors.secondary),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.two_wheeler_rounded, size: 16),
          label: Text(
            'Kurir Mengantar',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.selesai:
        return OutlinedButton.icon(
          onPressed: onActionTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            side: const BorderSide(color: AppColors.success),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.check_rounded, size: 16),
          label: Text(
            'Lihat Nota',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.success,
              fontSize: 12.5,
            ),
          ),
        );

      case AdminOrderStatus.dibatalkan:
        return OutlinedButton(
          onPressed: onActionTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Alasan Batal',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
              fontSize: 12.5,
            ),
          ),
        );
    }
  }
}
