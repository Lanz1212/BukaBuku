import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Store Gallery / Atmosphere Photo Card
class StoreGalleryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const StoreGalleryCard({
    super.key,
    this.title = 'Suasana Gerai Cikini Raya',
    this.subtitle = 'Ruang temu pecinta literatur sejak 1984',
    this.imagePath = 'assets/images/bookstore_camera_sim.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryContainer,
                  child: const Center(
                    child: Icon(
                      Icons.storefront_rounded,
                      color: AppColors.onPrimary,
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Content text at bottom
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
