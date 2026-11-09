import 'package:flutter/material.dart';
import '../../../../core/models/admin_notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AdminNotificationCard extends StatelessWidget {
  final AdminNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AdminNotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  String _getCategoryLabel() {
    switch (item.category) {
      case AdminNotifCategory.order:
        return 'Pesanan';
      case AdminNotifCategory.stock:
        return 'Stok';
      case AdminNotifCategory.inventory:
        return 'Katalog';
      case AdminNotifCategory.all:
        return 'Sistem';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notif-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 24,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isUnread
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerLow.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isUnread
                ? AppColors.primary.withValues(alpha: 0.22)
                : AppColors.outlineVariant.withValues(alpha: 0.35),
            width: item.isUnread ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: item.isUnread
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.iconContainerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag & Time Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.iconColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getCategoryLabel(),
                                style: AppTypography.caption.copyWith(
                                  color: item.iconColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.5,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),

                            // Unread indicator dot + Time
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.isUnread) ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                Text(
                                  item.timeAgo,
                                  style: AppTypography.caption.copyWith(
                                    color: item.isUnread
                                        ? AppColors.onSurface
                                        : AppColors.outline,
                                    fontWeight: item.isUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          item.title,
                          style: AppTypography.titleMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: item.isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Body
                        Text(
                          item.body,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.35,
                            fontSize: 12.5,
                          ),
                        ),

                        // Order ID / Reference Pill (if available)
                        if (item.orderId != null && item.orderId!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.receipt_outlined,
                                  size: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '#${item.orderId}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

