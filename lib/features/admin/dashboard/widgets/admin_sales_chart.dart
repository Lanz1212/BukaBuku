import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/models/monthly_sales_data.dart';

class AdminSalesChart extends StatefulWidget {
  final int? year;

  const AdminSalesChart({
    super.key,
    this.year,
  });

  @override
  State<AdminSalesChart> createState() => _AdminSalesChartState();
}

class _AdminSalesChartState extends State<AdminSalesChart> {
  List<MonthlySalesData> _monthlyData = [];
  bool _isLoading = true;
  late int _targetYear;
  int? _selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    _targetYear = widget.year ?? DateTime.now().year;
    _loadSalesData();
  }

  @override
  void didUpdateWidget(covariant AdminSalesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.year != null && widget.year != _targetYear) {
      _targetYear = widget.year!;
      _loadSalesData();
    }
  }

  Future<void> _loadSalesData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await PaymentService.fetchMonthlySalesChart(
        targetYear: _targetYear,
      );
      if (mounted) {
        setState(() {
          _monthlyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading monthly sales chart: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCompact(int amount) {
    if (amount <= 0) return 'Rp0';
    if (amount >= 1000000000) {
      final val = (amount / 1000000000).toStringAsFixed(1).replaceAll('.', ',');
      return 'Rp$val M';
    }
    if (amount >= 1000000) {
      final val = (amount / 1000000).toStringAsFixed(2).replaceAll('.', ',');
      return 'Rp$val Jt';
    }
    if (amount >= 1000) {
      final val = (amount / 1000).toStringAsFixed(0);
      return 'Rp$val Rb';
    }
    return 'Rp$amount';
  }

  String _formatPrice(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalAnnualSales = _monthlyData.fold<int>(
      0,
      (sum, item) => sum + item.totalRevenue,
    );
    final totalAnnualOrders = _monthlyData.fold<int>(
      0,
      (sum, item) => sum + item.orderCount,
    );

    final currentMonth = DateTime.now().month;

    MonthlySalesData? activeMonthData;
    if (_selectedMonthIndex != null &&
        _selectedMonthIndex! >= 0 &&
        _selectedMonthIndex! < _monthlyData.length) {
      activeMonthData = _monthlyData[_selectedMonthIndex!];
    }

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
                    Row(
                      children: [
                        Text(
                          'Grafik Penjualan Bulanan',
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$_targetYear',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryContainer,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeMonthData != null
                          ? '${activeMonthData.monthNameFull}: ${_formatPrice(activeMonthData.totalRevenue)} (${activeMonthData.orderCount} pesanan)'
                          : 'Januari - Desember $_targetYear • Data Realtime',
                      style: AppTypography.caption.copyWith(
                        color: activeMonthData != null
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight: activeMonthData != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCompact(totalAnnualSales),
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryContainer,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$totalAnnualOrders pesanan lunas',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Painted Monthly Bar Chart
          if (_isLoading)
            Container(
              height: 130,
              width: double.infinity,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.primaryContainer,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 120,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final width = constraints.maxWidth;
                      final step = width / 12;
                      final clickedIndex = (details.localPosition.dx / step).floor();
                      if (clickedIndex >= 0 && clickedIndex < 12) {
                        setState(() {
                          _selectedMonthIndex =
                              _selectedMonthIndex == clickedIndex ? null : clickedIndex;
                        });
                      }
                    },
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 120),
                      painter: _MonthlySalesChartPainter(
                        monthlyData: _monthlyData,
                        currentMonth: currentMonth,
                        selectedIndex: _selectedMonthIndex,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 12 Months Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(12, (index) {
                final monthNum = index + 1;
                const shortNames = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'Mei',
                  'Jun',
                  'Jul',
                  'Agu',
                  'Sep',
                  'Okt',
                  'Nov',
                  'Des'
                ];
                final isCurrent = monthNum == currentMonth;
                final isSelected = _selectedMonthIndex == index;
                final hasSales = index < _monthlyData.length &&
                    _monthlyData[index].totalRevenue > 0;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMonthIndex =
                          _selectedMonthIndex == index ? null : index;
                    });
                  },
                  child: SizedBox(
                    width: 22,
                    child: Text(
                      shortNames[index],
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : (isCurrent
                                ? AppColors.primaryContainer
                                : (hasSales
                                    ? AppColors.onSurface
                                    : AppColors.outlineVariant)),
                        fontWeight: (isSelected || isCurrent || hasSales)
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 9.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthlySalesChartPainter extends CustomPainter {
  final List<MonthlySalesData> monthlyData;
  final int currentMonth;
  final int? selectedIndex;

  _MonthlySalesChartPainter({
    required this.monthlyData,
    required this.currentMonth,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRevenue = monthlyData.fold<int>(
      0,
      (maxVal, item) => max(maxVal, item.totalRevenue),
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double h = size.height - 12;
    // Draw 3 horizontal guideline reference lines
    canvas.drawLine(const Offset(0, 5), Offset(size.width, 5), gridPaint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(size.width, h * 0.5), gridPaint);
    canvas.drawLine(Offset(0, h), Offset(size.width, h), gridPaint);

    const int count = 12;
    final double step = size.width / count;
    // Lebar bar proporsional
    final double barWidth = min(16.0, step * 0.55);

    for (int i = 0; i < count; i++) {
      final revenue = i < monthlyData.length ? monthlyData[i].totalRevenue : 0;
      final double ratio = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;

      final double x = (i * step) + (step - barWidth) / 2;

      // Jika bulan itu kosong, hanya tampilkan titik dasar / indikator nol tipis
      if (revenue == 0) {
        final zeroPaint = Paint()
          ..color = AppColors.outlineVariant.withValues(alpha: 0.25)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2;
        canvas.drawLine(Offset(x, h), Offset(x + barWidth, h), zeroPaint);
        continue;
      }

      // Bar height minimal 6px jika ada penjualan agar tetap terlihat
      final double availableHeight = h - 8;
      final double barHeight = max(6.0, ratio * availableHeight);
      final double y = h - barHeight;

      final isSelected = selectedIndex == i;
      final isCurrent = (i + 1) == currentMonth;

      final RRect barRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      Color barColor;
      if (isSelected) {
        barColor = AppColors.primary;
      } else if (isCurrent) {
        barColor = AppColors.primaryContainer;
      } else {
        barColor = const Color(0xFF6366F1); // Indigo accent
      }

      final barPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(barRRect, barPaint);

      // Jika dipilih atau merupakan puncak penjualan, gambar lingkaran indikator kecil di atas bar
      if (isSelected || (maxRevenue > 0 && revenue == maxRevenue)) {
        final capPaint = Paint()
          ..color = isSelected ? AppColors.primary : AppColors.primaryContainer
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x + barWidth / 2, y - 4), 2.5, capPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlySalesChartPainter oldDelegate) {
    return oldDelegate.monthlyData != monthlyData ||
        oldDelegate.currentMonth != currentMonth ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
