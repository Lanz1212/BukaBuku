import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_order_detail.dart';

class OrderStatusChip extends StatelessWidget {
  final AdminOrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final detail = AdminOrderDetail(
      orderId: '',
      orderTime: '',
      customerName: '',
      customerPhone: '',
      deliveryType: '',
      paymentMethod: '',
      isPaid: false,
      status: status,
      books: const [],
      totalPrice: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: detail.statusBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: detail.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            detail.statusLabel,
            style: AppTypography.caption.copyWith(
              color: detail.statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
