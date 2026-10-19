import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Cashier QR Code ticket display card.
/// Renders an authentic bookstore QR token for cashier checkout.
class OrderCashierQrCard extends StatelessWidget {
  final String qrCodeText;
  final String cashierInstructions;

  const OrderCashierQrCard({
    super.key,
    this.qrCodeText = 'ORD-00125-CKN',
    this.cashierInstructions =
        'Tunjukkan QR Code ini kepada kasir saat mengambil pesanan',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'SCAN QR CODE DI KASIR TOKO',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),

          // QR Code Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _StoreQrPainter(color: AppColors.primary),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Monospace Code Label
          Text(
            qrCodeText,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 6),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              cashierInstructions,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws authentic QR Code finder patterns and matrix blocks
/// matching the SVG from the design reference.
class _StoreQrPainter extends CustomPainter {
  final Color color;

  const _StoreQrPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double scale = size.width / 100.0;

    void drawFinder(double x, double y) {
      // Outer rounded square
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * scale, y * scale, 28 * scale, 28 * scale),
          Radius.circular(4 * scale),
        ),
        paint,
      );
      // Inner white cut
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              (x + 6) * scale, (y + 6) * scale, 16 * scale, 16 * scale),
          Radius.circular(2 * scale),
        ),
        whitePaint,
      );
      // Center dot
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              (x + 10) * scale, (y + 10) * scale, 8 * scale, 8 * scale),
          Radius.circular(1.5 * scale),
        ),
        paint,
      );
    }

    // Top-Left Finder
    drawFinder(5, 5);
    // Top-Right Finder
    drawFinder(67, 5);
    // Bottom-Left Finder
    drawFinder(5, 67);

    // Data matrix blocks
    void drawBlock(double x, double y, double w, double h, [double r = 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * scale, y * scale, w * scale, h * scale),
          Radius.circular(r * scale),
        ),
        paint,
      );
    }

    // Timing & synchronization blocks
    drawBlock(39, 8, 6, 6);
    drawBlock(51, 8, 6, 6);
    drawBlock(39, 20, 6, 6);
    drawBlock(51, 20, 6, 6);

    drawBlock(8, 39, 6, 6);
    drawBlock(20, 39, 6, 6);
    drawBlock(8, 51, 6, 6);
    drawBlock(20, 51, 6, 6);

    // Inner random data clusters
    drawBlock(35, 35, 10, 10, 2);
    drawBlock(55, 35, 8, 8);
    drawBlock(48, 48, 12, 12, 2);
    drawBlock(35, 55, 8, 8);
    drawBlock(68, 48, 7, 7);
    drawBlock(82, 40, 8, 8);
    drawBlock(78, 60, 9, 9);
    drawBlock(40, 72, 8, 8);
    drawBlock(55, 70, 8, 8);
    drawBlock(42, 85, 7, 7);
    drawBlock(58, 83, 8, 8);
    drawBlock(72, 76, 10, 10, 2);
    drawBlock(86, 85, 7, 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
