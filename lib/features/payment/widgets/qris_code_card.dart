import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Interactive QRIS display card with BI standard branding,
/// custom bookstore QR visual, merchant details, and download button.
class QrisCodeCard extends StatelessWidget {
  final String merchantName;
  final String nmid;
  final VoidCallback? onDownload;

  const QrisCodeCard({
    super.key,
    this.merchantName = 'Toko Buku Budi Cikini',
    this.nmid = 'NMID: ID1020038891002',
    this.onDownload,
  });

  void _handleDownload(BuildContext context) {
    if (onDownload != null) {
      onDownload!();
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Kode QR berhasil disimpan ke galeri perangkat Anda.'),
          ],
        ),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // QRIS Header Row (QRIS Standar BI & GPN)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'QRIS',
                      style: AppTypography.titleMd.copyWith(
                        color: const Color(0xFFD9534F), // QRIS red brand
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Standar BI',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'GPN',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Merchant Name & NMID
          Text(
            merchantName,
            style: AppTypography.titleMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nmid,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 14),

          // Tactile Bookstore QR Visual Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const SizedBox(
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: _BookstoreQRPainter(),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Caption Subtext
          Text(
            'Pindai kode QR melalui aplikasi perbankan atau dompet digital Anda',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // Download QR Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _handleDownload(context),
              icon: const Icon(
                Icons.download_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Unduh Kode QR',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that renders a realistic bookstore QRIS code pattern
/// with corner finder patterns and center bookstore emblem.
class _BookstoreQRPainter extends CustomPainter {
  const _BookstoreQRPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const qrColor = Color(0xFF433021); // Coffee timber primary
    final paintFill = Paint()..color = qrColor;
    final paintWhite = Paint()..color = Colors.white;

    final w = size.width;
    final h = size.height;

    // Outer corner reticles / brackets
    const bracketSize = 10.0;
    const bracketWidth = 2.5;
    final bracketPaint = Paint()
      ..color = qrColor
      ..strokeWidth = bracketWidth
      ..style = PaintingStyle.stroke;

    // Top-left bracket
    canvas.drawLine(const Offset(2, 2 + bracketSize), const Offset(2, 2), bracketPaint);
    canvas.drawLine(const Offset(2, 2), const Offset(2 + bracketSize, 2), bracketPaint);

    // Top-right bracket
    canvas.drawLine(Offset(w - 2 - bracketSize, 2), Offset(w - 2, 2), bracketPaint);
    canvas.drawLine(Offset(w - 2, 2), Offset(w - 2, 2 + bracketSize), bracketPaint);

    // Bottom-left bracket
    canvas.drawLine(Offset(2, h - 2 - bracketSize), Offset(2, h - 2), bracketPaint);
    canvas.drawLine(Offset(2, h - 2), Offset(2 + bracketSize, h - 2), bracketPaint);

    // Bottom-right bracket
    canvas.drawLine(Offset(w - 2 - bracketSize, h - 2), Offset(w - 2, h - 2), bracketPaint);
    canvas.drawLine(Offset(w - 2, h - 2), Offset(w - 2, h - 2 - bracketSize), bracketPaint);

    // 3 Main Finder Patterns (Top-Left, Top-Right, Bottom-Left)
    void drawFinder(double x, double y, double finderSize) {
      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, finderSize, finderSize),
        const Radius.circular(6),
      );
      canvas.drawRRect(outerRRect, paintFill);

      const inset1 = 6.0;
      final midRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + inset1, y + inset1, finderSize - inset1 * 2, finderSize - inset1 * 2),
        const Radius.circular(3),
      );
      canvas.drawRRect(midRRect, paintWhite);

      const inset2 = 12.0;
      final innerRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + inset2, y + inset2, finderSize - inset2 * 2, finderSize - inset2 * 2),
        const Radius.circular(2),
      );
      canvas.drawRRect(innerRRect, paintFill);
    }

    const fSize = 46.0;
    const margin = 10.0;

    // Top-Left
    drawFinder(margin, margin, fSize);
    // Top-Right
    drawFinder(w - margin - fSize, margin, fSize);
    // Bottom-Left
    drawFinder(margin, h - margin - fSize, fSize);

    // Data Cluster Blocks
    final dotRects = [
      // Top row clusters
      Rect.fromLTWH(margin + fSize + 10, margin + 4, 10, 10),
      Rect.fromLTWH(margin + fSize + 26, margin + 4, 10, 10),
      Rect.fromLTWH(margin + fSize + 42, margin + 4, 10, 10),
      Rect.fromLTWH(margin + fSize + 10, margin + 22, 10, 10),
      Rect.fromLTWH(margin + fSize + 42, margin + 22, 10, 10),
      Rect.fromLTWH(margin + fSize + 26, margin + 34, 10, 10),

      // Left middle
      Rect.fromLTWH(margin + 4, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(margin + 22, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(margin + 38, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(margin + 10, margin + fSize + 28, 10, 10),
      Rect.fromLTWH(margin + 32, margin + fSize + 28, 10, 10),
      Rect.fromLTWH(margin + 4, margin + fSize + 46, 10, 10),
      Rect.fromLTWH(margin + 38, margin + fSize + 46, 10, 10),

      // Right middle
      Rect.fromLTWH(w - margin - fSize + 2, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 20, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 36, margin + fSize + 10, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 10, margin + fSize + 28, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 32, margin + fSize + 28, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 2, margin + fSize + 46, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 24, margin + fSize + 46, 10, 10),

      // Bottom right
      Rect.fromLTWH(w - margin - fSize + 2, h - margin - fSize + 4, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 20, h - margin - fSize + 4, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 2, h - margin - fSize + 22, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 32, h - margin - fSize + 22, 10, 10),
      Rect.fromLTWH(w - margin - fSize + 14, h - margin - fSize + 36, 10, 10),

      // Bottom middle
      Rect.fromLTWH(margin + fSize + 10, h - margin - fSize + 4, 10, 10),
      Rect.fromLTWH(margin + fSize + 42, h - margin - fSize + 4, 10, 10),
      Rect.fromLTWH(margin + fSize + 26, h - margin - fSize + 18, 10, 10),
      Rect.fromLTWH(margin + fSize + 10, h - margin - fSize + 34, 10, 10),
      Rect.fromLTWH(margin + fSize + 42, h - margin - fSize + 34, 10, 10),
    ];

    for (final r in dotRects) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), paintFill);
    }

    // Center Bookstore Emblem
    final cx = w / 2;
    final cy = h / 2;

    // White backing circle
    canvas.drawCircle(Offset(cx, cy), 22, paintWhite);
    // Dark brown outer circle
    canvas.drawCircle(Offset(cx, cy), 18, paintFill);

    // White open book icon inside center emblem
    final bookPath = Path()
      ..moveTo(cx - 7, cy - 5)
      ..lineTo(cx - 3, cy - 8)
      ..lineTo(cx + 3, cy - 8)
      ..lineTo(cx + 7, cy - 5)
      ..lineTo(cx + 7, cy + 6)
      ..lineTo(cx + 3, cy + 3)
      ..lineTo(cx - 3, cy + 3)
      ..lineTo(cx - 7, cy + 6)
      ..close();
    canvas.drawPath(bookPath, paintWhite);

    final spinePaint = Paint()
      ..color = qrColor
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(cx, cy - 7), Offset(cx, cy + 3), spinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
