import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable Info / Action Tile for Admin Panel
class AdminInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? titleBadge;
  final String? trailingBadge;
  final Color? trailingBadgeColor;
  final Color? trailingBadgeTextColor;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool isDestructive;

  const AdminInfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleBadge,
    this.trailingBadge,
    this.trailingBadgeColor,
    this.trailingBadgeTextColor,
    this.iconColor,
    this.iconBgColor,
    this.titleColor,
    this.onTap,
    this.showDivider = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitleColor = titleColor ??
        (isDestructive ? AppColors.error : AppColors.onSurface);
    final effectiveIconColor = iconColor ??
        (isDestructive ? AppColors.error : AppColors.primary);
    final effectiveIconBgColor = iconBgColor ??
        (isDestructive
            ? AppColors.errorContainer.withValues(alpha: 0.6)
            : AppColors.surfaceContainerHigh);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primaryFixed.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                children: [
                  // Leading Icon Box
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: effectiveIconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: effectiveIconColor,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title, optional Title Badge, & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleMd.copyWith(
                                color: effectiveTitleColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.5,
                              ),
                            ),
                            if (titleBadge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  titleBadge!,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: AppTypography.caption.copyWith(
                              color: isDestructive
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.onSurfaceVariant,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing Badge
                  if (trailingBadge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: trailingBadgeColor ?? AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        trailingBadge!,
                        style: AppTypography.caption.copyWith(
                          color: trailingBadgeTextColor ?? AppColors.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Trailing Chevron
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDestructive
                        ? AppColors.error.withValues(alpha: 0.6)
                        : AppColors.outlineVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 68.0, right: 14.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}
