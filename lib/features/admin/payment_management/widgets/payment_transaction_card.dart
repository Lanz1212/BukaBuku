import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/payment_transaction.dart';
import 'payment_confirm_cash_sheet.dart';

class PaymentTransactionCard extends StatelessWidget {
  final PaymentTransaction transaction;
  final VoidCallback onCashConfirmed;
  final ValueChanged<PaymentTransaction> onShowInvoice;
  final ValueChanged<PaymentTransaction> onCheckStatus;

  const PaymentTransactionCard({
    super.key,
    required this.transaction,
    required this.onCashConfirmed,
    required this.onShowInvoice,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNeedsConfirmation =
        transaction.status == PaymentStatus.needsConfirmation;
    final bool isFailed = transaction.status == PaymentStatus.failed;

    Color cardBgColor = AppColors.surfaceContainerLowest;
    Color borderColor = AppColors.outlineVariant.withValues(alpha: 0.6);

    if (isNeedsConfirmation) {
      cardBgColor = const Color(0xFFFFFBF5);
      borderColor = AppColors.warning.withValues(alpha: 0.35);
    } else if (isFailed) {
      cardBgColor = const Color(0xFFFFF7F7);
      borderColor = AppColors.error.withValues(alpha: 0.25);
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    transaction.orderId,
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '• ${transaction.time}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 10),

          // Customer Row
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                transaction.customerName,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                transaction.customerPhone,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Payment Method Chip & Delivery Type
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMethodIcon(transaction.method),
                      size: 13,
                      color: AppColors.primaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.methodLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (transaction.deliveryType != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.deliveryType!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Books preview
          Text(
            transaction.bookTitles.join(', '),
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            height: 1,
          ),
          const SizedBox(height: 10),

          // Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    transaction.formattedTotal,
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isFailed
                          ? AppColors.onSurfaceVariant
                          : AppColors.onSurface,
                      fontSize: 16,
                      decoration: isFailed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
              _buildActionButton(context),
            ],
          ),

          if (isFailed && transaction.failureReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      transaction.failureReason!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bg;
    Color textColor;
    switch (transaction.status) {
      case PaymentStatus.needsConfirmation:
        bg = AppColors.warning.withValues(alpha: 0.14);
        textColor = AppColors.warning;
        break;
      case PaymentStatus.paid:
        bg = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        break;
      case PaymentStatus.pending:
        bg = const Color(0xFF2E78B7).withValues(alpha: 0.12);
        textColor = const Color(0xFF2E78B7);
        break;
      case PaymentStatus.failed:
        bg = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        transaction.statusLabel,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10.5,
        ),
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashPickup:
        return Icons.payments_outlined;
      case PaymentMethod.qrisOnline:
        return Icons.qr_code_2_rounded;
      case PaymentMethod.transferVA:
        return Icons.account_balance_outlined;
      case PaymentMethod.eWallet:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Widget _buildActionButton(BuildContext context) {
    switch (transaction.status) {
      case PaymentStatus.needsConfirmation:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: const Size(0, 36),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => PaymentConfirmCashSheet(
                transaction: transaction,
                onConfirmed: onCashConfirmed,
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_rounded, size: 16),
              SizedBox(width: 4),
              Text(
                'Konfirmasi Cash',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case PaymentStatus.paid:
        return TextButton.icon(
          onPressed: () => onShowInvoice(transaction),
          icon: const Icon(Icons.receipt_long_outlined, size: 15),
          label: const Text(
            'Lihat Invoice',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 36),
          ),
        );

      case PaymentStatus.pending:
        return OutlinedButton(
          onPressed: () => onCheckStatus(transaction),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryContainer,
            side: const BorderSide(color: AppColors.primaryContainer),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: const Size(0, 34),
          ),
          child: const Text(
            'Cek Status',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        );

      case PaymentStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Batal',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        );
    }
  }
}
