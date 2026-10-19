import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PickupSuccessStorePhoto extends StatelessWidget {
  final String imageUrl;
  final String locationLabel;

  const PickupSuccessStorePhoto({
    super.key,
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDX3oLp4fI1bQ1Q63NbkjRVpAORqWETKaNjhjX5ijB560tZDNwgv-EvI6QhhUQdz4HB4XyRAWRBcFzLrWvUlWFqVMw_7b9J6Tq0SKIvU41xIbPaxPVon7EJ6WQ7nPdix7TDMmxzjibW9aWqV3hWjPdobfP6i-sIifEyhNBeYTuZ42al3_FdBPaeKBfjqx9K0FRC4uf3YPzrneoFe0lB1Hn8qNRWvEyxpi5hbWRIzbXGblrqwvzPwmBMmQ',
    this.locationLabel = 'Gerai Cikini • Konter Pengambilan #01',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceContainerHigh,
              alignment: Alignment.center,
              child: const Icon(
                Icons.storefront,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          // Label at bottom
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: Row(
              children: [
                const Icon(
                  Icons.storefront,
                  size: 16,
                  color: AppColors.onPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  locationLabel,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
