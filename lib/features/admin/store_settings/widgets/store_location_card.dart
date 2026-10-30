import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Physical Store Location & Map Preview Card
class StoreLocationCard extends StatelessWidget {
  final TextEditingController addressController;
  final String coordinates;
  final VoidCallback? onPinpointMap;

  const StoreLocationCard({
    super.key,
    required this.addressController,
    this.coordinates = 'Cikini, Menteng (Lat: -6.1912, Long: 106.8404)',
    this.onPinpointMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Alamat Gerai Fisik',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                'Titik Verifikasi',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: TextField(
              controller: addressController,
              maxLines: 2,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 13,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Pinpoint Map Action Tile
          Material(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPinpointMap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tandai Pinpoint Peta Lokasi',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Presisi Akurat',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.outlineVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Map Preview Graphic
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 115,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E9EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Stylized map illustration background
                  CustomPaint(
                    size: const Size(double.infinity, 115),
                    painter: _MapGridPainter(),
                  ),

                  // Pinpoint badge banner
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            size: 16,
                            color: Color(0xFFD9534F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            coordinates,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylized Map grid painter mimicking Google Maps / OpenStreetMap road layout
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE9EDEE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFDCE2E6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final waterPaint = Paint()..color = const Color(0xFFCBE3F5);

    // River/water element
    final waterPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.85,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Main road horizontal
    canvas.drawLine(
      Offset(0, size.height * 0.48),
      Offset(size.width, size.height * 0.48),
      roadPaint,
    );

    // Diagonal road
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );

    // Secondary streets
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.2),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.85, size.height * 0.6),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.48),
      Offset(size.width * 0.15, size.height * 0.8),
      secondaryRoadPaint,
    );

    // Area labels text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'West Jakarta',
        style: TextStyle(
          color: Color(0xFF889096),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(12, 10));

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: 'East Jakarta',
        style: TextStyle(
          color: Color(0xFF889096),
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter2.layout();
    textPainter2.paint(canvas, Offset(size.width - 65, size.height - 18));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
