import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Logo & Visual Identity Card
class StoreLogoCard extends StatelessWidget {
  final VoidCallback? onChangeLogo;
  final VoidCallback? onDeleteLogo;

  const StoreLogoCard({
    super.key,
    this.onChangeLogo,
    this.onDeleteLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label with Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Logo & Identitas Visual',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Publik',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Logo Preview & Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo thumbnail container
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/Logo Toko Buku Budi.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.onPrimary,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Action Buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onChangeLogo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.photo_camera_outlined, size: 16),
                          label: Text(
                            'Ubah Logo',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: onDeleteLogo,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onSurfaceVariant,
                            side: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Hapus',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Format PNG, JPG maks 2MB (Rasio 1:1 direkomendasikan)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
