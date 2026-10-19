import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/payment_method_item.dart';

/// Card tile for each payment option in the Payment Method selection screen.
/// Implements custom radio indicator, left accent bar, logo chips, and badge styling.
class PaymentMethodOptionTile extends StatelessWidget {
  final PaymentMethodItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOptionTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? null
              : AppColors.surfaceContainerLowest,
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.surfaceContainerLow,
                    AppColors.surfaceContainerLowest,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.35)
                : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryContainer.withValues(alpha: 0.08)
                  : AppColors.primaryContainer.withValues(alpha: 0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left Vertical Accent Bar (when selected)
              if (isSelected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    color: AppColors.primaryContainer,
                  ),
                ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSelected ? 18 : 16,
                  16,
                  16,
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom Radio Indicator (20px circle)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: AppColors.outlineVariant,
                                width: 1.5,
                              ),
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(width: 14),

                    // Main Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title + Badge / Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: AppTypography.labelLg.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (item.badge != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.isFastest
                                        ? AppColors.primaryFixed
                                        : AppColors.secondaryFixed,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (item.requiresPickupOnly) ...[
                                        const Icon(
                                          Icons.store_outlined,
                                          size: 13,
                                          color: AppColors.onSecondaryFixed,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        item.badge!,
                                        style: AppTypography.caption.copyWith(
                                          color: item.isFastest
                                              ? AppColors.onPrimaryFixed
                                              : AppColors.onSecondaryFixed,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (item.icon != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Subtitle
                          Text(
                            item.subtitle,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),

                          // Logo Chips Row (for QRIS / E-Wallets)
                          if (item.chips.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: item.chips.map((chip) {
                                final isQrisPill = chip == 'QRIS';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    chip,
                                    style: AppTypography.caption.copyWith(
                                      color: isQrisPill
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: isQrisPill
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Subline with Icon (e.g., Konfirmasi Instan or 3 hari kerja)
                          if (item.subline != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (item.sublineIcon != null) ...[
                                  Icon(
                                    item.sublineIcon,
                                    size: 14,
                                    color: item.requiresPickupOnly
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Expanded(
                                  child: Text(
                                    item.subline!,
                                    style: AppTypography.caption.copyWith(
                                      color: item.requiresPickupOnly
                                          ? AppColors.secondary
                                          : AppColors.onSurfaceVariant,
                                      fontWeight: item.requiresPickupOnly
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
