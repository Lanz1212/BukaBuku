import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BookFormCoverUpload extends StatelessWidget {
  final String? coverUrl;
  final VoidCallback onPickCover;
  final VoidCallback onRemoveCover;

  const BookFormCoverUpload({
    super.key,
    required this.coverUrl,
    required this.onPickCover,
    required this.onRemoveCover,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cover Buku',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Rekomendasi 2:3',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Upload Area Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
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
          child: hasCover ? _buildPreviewState() : _buildPlaceholderState(),
        ),
      ],
    );
  }

  Widget _buildPlaceholderState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Upload Icon in circular warm container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.secondary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          'Unggah Foto Cover Buku',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Maksimal 2MB, format JPG atau PNG (Rasio standar 2:3 untuk rak vertikal)',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.5,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 14),

        // Button Pilih Berkas
        ElevatedButton.icon(
          onPressed: onPickCover,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceContainer,
            foregroundColor: AppColors.onSurfaceVariant,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          icon: const Icon(Icons.file_upload_outlined, size: 17),
          label: Text(
            'Pilih Berkas',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewState() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 2:3 Aspect ratio container
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 120,
              height: 180,
              child: Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.outline,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Remove Button
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemoveCover,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
