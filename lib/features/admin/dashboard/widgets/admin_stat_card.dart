import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_stat_item.dart';

class AdminStatCard extends StatelessWidget {
  final AdminStatItem item;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHighlight = item.isHighlight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.secondaryContainer.withValues(alpha: 0.38)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHighlight
                  ? AppColors.secondary.withValues(alpha: 0.25)
                  : AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Title + Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTypography.caption.copyWith(
                        color: isHighlight
                            ? AppColors.onSecondaryContainer
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isHighlight
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item.icon,
                      size: 16,
                      color: isHighlight
                          ? AppColors.onSecondaryContainer
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Middle: Value + Unit or Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.value,
                    style: AppTypography.headlineMd.copyWith(
                      color: isHighlight
                          ? AppColors.onSecondaryContainer
                          : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: item.value.length > 8 ? 16 : 20,
                    ),
                  ),
                  if (item.unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      item.unit,
                      style: AppTypography.caption.copyWith(
                        color: isHighlight
                            ? AppColors.onSecondaryContainer
                            : AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (item.badgeText != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        item.badgeText!,
                        style: const TextStyle(
                          color: AppColors.onSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Bottom: Subtitle with subtle icon
              Row(
                children: [
                  Icon(
                    isHighlight
                        ? Icons.schedule_rounded
                        : (item.subtitle.contains('+')
                            ? Icons.add_circle_outline_rounded
                            : Icons.check_circle_outline_rounded),
                    size: 12,
                    color: isHighlight
                        ? AppColors.onSecondaryContainer.withValues(alpha: 0.8)
                        : (item.subtitle.contains('+')
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: isHighlight
                            ? AppColors.onSecondaryContainer
                                .withValues(alpha: 0.85)
                            : (item.subtitle.contains('+')
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant),
                        fontSize: 11,
                        fontWeight: item.subtitle.contains('+')
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
