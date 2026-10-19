import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/notification_model.dart';
import 'notification_qr_action.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onOpenQrPickup;
  final VoidCallback? onWriteReview;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onOpenQrPickup,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isUnread
              ? AppColors.secondary.withValues(alpha: 0.25)
              : AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(
              alpha: notification.isUnread ? 0.08 : 0.03,
            ),
            blurRadius: notification.isUnread ? 16 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with Unread Badge indicator
          _buildLeadingIcon(),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  notification.title,
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),

                // Time ago
                Text(
                  notification.timeAgo,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),

                // Body text
                Text(
                  notification.body,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),

                // Dynamic Action / Extra elements based on notification type
                _buildActionWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    Color bgColor;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.orderPickupReady:
        bgColor = AppColors.secondaryContainer.withValues(alpha: 0.4);
        iconColor = AppColors.secondary;
        break;
      case NotificationType.orderShipping:
      case NotificationType.orderCompleted:
        bgColor = AppColors.surfaceContainerHigh;
        iconColor = AppColors.onSurfaceVariant;
        break;
      case NotificationType.paymentSuccess:
        bgColor = AppColors.surfaceContainerHigh;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.orderProcessing:
        bgColor = AppColors.surfaceContainer;
        iconColor = AppColors.primaryContainer;
        break;
      case NotificationType.promoVoucher:
        bgColor = AppColors.secondaryFixed.withValues(alpha: 0.5);
        iconColor = AppColors.onSecondaryFixedVariant;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            notification.icon,
            size: 24,
            color: iconColor,
          ),
        ),
        if (notification.isUnread)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionWidget(BuildContext context) {
    switch (notification.type) {
      case NotificationType.orderPickupReady:
        return NotificationQrAction(
          onTap: onOpenQrPickup ?? () {},
        );

      case NotificationType.orderShipping:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pin_drop_outlined,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  notification.deliveryEta ?? 'Estimasi tiba sore ini',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );

      case NotificationType.paymentSuccess:
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 14,
                color: AppColors.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'No. Ref: ${notification.refId ?? 'QRIS-9928104'}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );

      case NotificationType.orderCompleted:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: OutlinedButton(
            onPressed: onWriteReview ?? () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.primary,
              side: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(0, 34),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rate_review_outlined, size: 15, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Tulis Ulasan Buku',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      case NotificationType.promoVoucher:
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berlaku sampai akhir pekan',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (notification.voucherCode != null) {
                    Clipboard.setData(ClipboardData(text: notification.voucherCode!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kode voucher "${notification.voucherCode}" disalin!'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Salin Kode',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case NotificationType.orderProcessing:
        return const SizedBox.shrink();
    }
  }
}
