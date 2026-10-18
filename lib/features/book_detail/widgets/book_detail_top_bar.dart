import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Top App Bar specifically tailored for the Book Detail screen
class BookDetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFavorite;
  final VoidCallback? onBackPressed;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onSharePressed;

  const BookDetailTopBar({
    super.key,
    this.isFavorite = false,
    this.onBackPressed,
    this.onFavoriteToggle,
    this.onSharePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 26,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),

              // Center: Icon + Title
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '📖',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detail Buku',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.5,
                    ),
                  ),
                ],
              ),

              // Right Actions: Favorite & Share
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: isFavorite ? const Color(0xFFD9534F) : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSharePressed,
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.share_outlined,
                          size: 19,
                          color: AppColors.onSurface,
                        ),
                      ),
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
