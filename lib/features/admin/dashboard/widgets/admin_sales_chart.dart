import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AdminSalesChart extends StatelessWidget {
  const AdminSalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Penjualan Mingguan',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Senin - Minggu ini • Puncak di akhir pekan',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp2,35 Jt',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Rata-rata Rp120rb/buku',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Painted Bar Chart
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeeklySalesChartPainter(),
            ),
          ),
          const SizedBox(height: 8),

          // Days labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayLabel('Sen'),
              _DayLabel('Sel'),
              _DayLabel('Rab'),
              _DayLabel('Kam'),
              _DayLabel('Jum'),
              _DayLabel('Sab', isHighlight: true),
              _DayLabel('Min', isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  final bool isHighlight;

  const _DayLabel(this.text, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(
          color: isHighlight ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _WeeklySalesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 7 days data percentages (0.0 to 1.0)
    final values = [0.38, 0.45, 0.32, 0.55, 0.72, 0.95, 0.82];
    final isPeak = [false, false, false, false, false, true, false];

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double h = size.height - 10;
    // Draw 3 horizontal lines
    canvas.drawLine(Offset(0, 5), Offset(size.width, 5), gridPaint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(size.width, h * 0.5), gridPaint);
    canvas.drawLine(Offset(0, h), Offset(size.width, h), gridPaint);

    final int count = values.length;
    final double step = size.width / count;
    const double barWidth = 18.0;

    for (int i = 0; i < count; i++) {
      final double barHeight = values[i] * (h - 10);
      final double x = (i * step) + (step - barWidth) / 2;
      final double y = h - barHeight;

      final RRect barRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      );

      final barPaint = Paint()
        ..color = isPeak[i]
            ? AppColors.primary
            : (i >= 4
                ? AppColors.primaryContainer
                : AppColors.secondaryContainer);

      canvas.drawRRect(barRRect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
