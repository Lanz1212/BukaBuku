import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Ambient Background Top Left
            Positioned(
              top: -150,
              left: MediaQuery.of(context).size.width / 2 - 200,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            // Ambient Background Bottom Right
            Positioned(
              bottom: 40,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryFixed.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),

            // Top Right Pill
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pustaka Terkurasi',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container with glow
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixedDim.withValues(alpha: 0.6),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida/AEtjO1UPQHX1Q3EW8OQ_Qf6soD1x18z7f6EvFrnkRipRVKnL6vo1lBRv3QZiURJzuV_ZmCR9fvmyXjadxBrze2Oa4xIVr6d7EBE4Zz5DU7Ncl_1it-hvgiuYfEzm7-dtpCa1dw223XAUYdMOWpgzqqMCPLxGdUwHKzvB5bX9Q_947x8e-maGSQenxvssTOWH5Q5eSnr8rGyhSV0lWm3di2VwEfd2TR7AmSCTLxdyZz6DpHxT1No5pw46RWMgeQyn',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image fails to load
                          return const Icon(
                            Icons.book,
                            size: 40,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Toko Buku Budi',
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buku favoritmu, lebih mudah didapat.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Small Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_cafe,
                          size: 16,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Teman Membaca Tenang',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Content
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Loading Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          double delay = index * 0.2;
                          double t = (_animationController.value - delay) % 1.0;
                          if (t < 0) t += 1.0;

                          // opacity pulse
                          double opacity = 1.0;
                          if (t < 0.5) {
                            opacity = 0.3 + (0.7 * (1 - (t * 2)));
                          } else {
                            opacity = 0.3 + (0.7 * ((t - 0.5) * 2));
                          }

                          Color dotColor = AppColors.primary;
                          if (index == 0) dotColor = AppColors.secondary;
                          if (index == 1) dotColor = AppColors.primaryContainer;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor.withValues(alpha: opacity),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'v1.0.0',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: AppColors.secondary.withValues(alpha: 0.4),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        'Toko Buku Resmi',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
