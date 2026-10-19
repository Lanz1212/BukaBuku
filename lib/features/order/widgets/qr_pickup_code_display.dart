import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class BarcodeQrPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  const BarcodeQrPainter({
    this.primaryColor = AppColors.primaryContainer,
    this.secondaryColor = AppColors.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    // Outer corner finder patterns (top-left, top-right, bottom-left)
    void drawFinderPattern(double x, double y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 44, 44),
          const Radius.circular(8),
        ),
        strokePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 11, y + 11, 22, 22),
          const Radius.circular(4),
        ),
        primaryPaint,
      );
    }

    drawFinderPattern(6, 6);
    drawFinderPattern(size.width - 50, 6);
    drawFinderPattern(6, size.height - 50);

    // Decorative Data Modules Matrix (Warm Editorial Pattern)
    final primaryRects = [
      const Rect.fromLTWH(76, 12, 18, 10),
      const Rect.fromLTWH(62, 38, 18, 10),
      const Rect.fromLTWH(86, 30, 10, 24),
      const Rect.fromLTWH(14, 62, 12, 12),
      const Rect.fromLTWH(12, 82, 20, 10),
      const Rect.fromLTWH(40, 90, 12, 12),
      const Rect.fromLTWH(62, 62, 16, 16),
      const Rect.fromLTWH(106, 62, 12, 20),
      const Rect.fromLTWH(152, 62, 16, 16),
      const Rect.fromLTWH(62, 124, 14, 20),
      const Rect.fromLTWH(108, 110, 12, 26),
      const Rect.fromLTWH(154, 106, 16, 20),
      const Rect.fromLTWH(90, 142, 14, 22),
      const Rect.fromLTWH(110, 142, 20, 10),
      const Rect.fromLTWH(158, 134, 12, 30),
    ];

    final secondaryRects = [
      const Rect.fromLTWH(62, 12, 10, 16),
      const Rect.fromLTWH(100, 12, 14, 14),
      const Rect.fromLTWH(102, 34, 18, 12),
      const Rect.fromLTWH(32, 62, 10, 18),
      const Rect.fromLTWH(18, 106, 14, 14),
      const Rect.fromLTWH(84, 62, 16, 10),
      const Rect.fromLTWH(124, 62, 20, 12),
      const Rect.fromLTWH(82, 118, 18, 12),
      const Rect.fromLTWH(126, 106, 20, 12),
      const Rect.fromLTWH(62, 152, 20, 12),
      const Rect.fromLTWH(138, 134, 14, 14),
      const Rect.fromLTWH(130, 154, 18, 12),
    ];

    for (final rect in primaryRects) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        primaryPaint,
      );
    }

    for (final rect in secondaryRects) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        secondaryPaint,
      );
    }

    // Center Core Emblem Area (warm background + bookstore emblem)
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 44,
      height: 44,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFF8F6F2),
    );

    final emblemCircle = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 32,
      height: 32,
    );
    canvas.drawOval(emblemCircle, primaryPaint);

    // Book emblem lines in white inside the circle
    final bookLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 7, cy - 4), Offset(cx + 7, cy - 4), bookLinePaint);
    canvas.drawLine(Offset(cx - 7, cy), Offset(cx + 7, cy), bookLinePaint);
    canvas.drawLine(Offset(cx - 7, cy + 4), Offset(cx + 4, cy + 4), bookLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QrPickupCodeDisplay extends StatelessWidget {
  const QrPickupCodeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: BarcodeQrPainter(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sync,
                size: 15,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Perbarui otomatis tiap 60 dtk',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
