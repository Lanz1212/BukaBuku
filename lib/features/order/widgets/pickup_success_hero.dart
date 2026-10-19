import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class _StampCirclePainter extends CustomPainter {
  final Color color;

  const _StampCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Inner circle
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 36, innerPaint);

    // Outer dashed circle
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashCount = 36;
    const radius = 44.0;
    const sweep = (2 * 3.1415926535) / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        false,
        outerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PickupSuccessHero extends StatelessWidget {
  final String title;
  final String subtitle;

  const PickupSuccessHero({
    super.key,
    this.title = 'Pesanan Berhasil Diambil!',
    this.subtitle =
        'Pesanan telah diserahkan kepada customer di gerai Toko Buku Budi Cikini. Selamat menikmati bacaan barumu!',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Organic Halo + Stamp Vector Graphic
        Center(
          child: SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Organic background glow
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),

                // Dashed and solid stamp circle
                const SizedBox(
                  width: 92,
                  height: 92,
                  child: CustomPaint(
                    painter: _StampCirclePainter(color: AppColors.secondary),
                  ),
                ),

                // White pill center with Success Check
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 34,
                    color: AppColors.success,
                  ),
                ),

                // Bottom right auto_stories badge
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.auto_stories,
                      size: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Headline
        Text(
          title,
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
