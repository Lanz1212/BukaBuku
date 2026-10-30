import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class QrViewfinderWidget extends StatefulWidget {
  final bool isTorchOn;
  final VoidCallback? onScanTriggered;
  final ValueChanged<double>? onZoomChanged;

  const QrViewfinderWidget({
    super.key,
    this.isTorchOn = false,
    this.onScanTriggered,
    this.onZoomChanged,
  });

  @override
  State<QrViewfinderWidget> createState() => _QrViewfinderWidgetState();
}

class _QrViewfinderWidgetState extends State<QrViewfinderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  double _currentZoom = 1.0;
  bool _showFocusRing = false;
  Offset _focusPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    setState(() {
      _focusPoint = details.localPosition;
      _showFocusRing = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _showFocusRing = false;
        });
      }
    });

    widget.onScanTriggered?.call();
  }

  void _selectZoom(double zoom) {
    if (_currentZoom == zoom) return;
    setState(() {
      _currentZoom = zoom;
    });
    widget.onZoomChanged?.call(zoom);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewfinderHeight = (constraints.maxWidth * 1.15).clamp(360.0, 430.0);

        return GestureDetector(
          onTapDown: _handleTap,
          child: Container(
            height: viewfinderHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1614),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF241A12).withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Simulated bookstore camera background with smooth zoom
                AnimatedScale(
                  scale: _currentZoom == 2.0 ? 1.35 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/bookstore_camera_sim.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback graceful dark aesthetic gradient if asset is loading
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF251E19), Color(0xFF14110E)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          );
                        },
                      ),
                      // Darkening + torch tint overlay
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: widget.isTorchOn
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.52),
                      ),
                      // Torch glow light effect if on
                      if (widget.isTorchOn)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.85,
                                colors: [
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Camera Viewport Status Header
                Positioned(
                  top: 16,
                  left: 18,
                  right: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Camera sensor status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sensors_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sensor Kamera Siaga',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Torch indicator
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isTorchOn
                                ? Icons.flashlight_on_rounded
                                : Icons.flashlight_off_rounded,
                            size: 15,
                            color: widget.isTorchOn
                                ? const Color(0xFFFDCB9B)
                                : Colors.white.withValues(alpha: 0.75),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.isTorchOn ? 'Senter Aktif' : 'Senter Mati',
                            style: AppTypography.caption.copyWith(
                              color: widget.isTorchOn
                                  ? const Color(0xFFFDCB9B)
                                  : Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. QR Target Box & Animated Laser Scanner
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom Painter for 4 warm amber corner brackets
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: const _QrCornerPainter(
                            cornerColor: Color(0xFFF2C299),
                            cornerLength: 42.0,
                            strokeWidth: 3.8,
                            cornerRadius: 16.0,
                          ),
                        ),

                        // Animated scanning laser line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            final laserY =
                                (_laserAnimation.value * 180) - 90; // -90 to +90
                            return Positioned(
                              top: 110 + laserY,
                              left: 14,
                              right: 14,
                              child: Container(
                                height: 2.2,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x00FDCB9B),
                                      Color(0xFFFDCB9B),
                                      Color(0xFFFFFFFF),
                                      Color(0xFFFDCB9B),
                                      Color(0x00FDCB9B),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFDCB9B)
                                          .withValues(alpha: 0.7),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Center QR Icon & "BIDIK QR"
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.qr_code_2_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'BIDIK QR',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Focus indicator ring on tap
                if (_showFocusRing)
                  Positioned(
                    left: _focusPoint.dx - 28,
                    top: _focusPoint.dy - 28,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.3, end: 1.0),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFDCB9B),
                                width: 1.8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // 5. Bottom Zoom Controls (1x, 2x)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildZoomOption(1.0, '1x'),
                          _buildZoomOption(2.0, '2x'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoomOption(double zoom, String label) {
    final isSelected = _currentZoom == zoom;
    return GestureDetector(
      onTap: () => _selectZoom(zoom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCDDC7) : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? const Color(0xFF28180B) : Colors.white,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _QrCornerPainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;

  const _QrCornerPainter({
    required this.cornerColor,
    required this.cornerLength,
    required this.strokeWidth,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    final double r = cornerRadius;
    final double arm = cornerLength;

    // 1. Top-Left Corner
    final pathTl = Path()
      ..moveTo(0, arm)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(arm, 0);
    canvas.drawPath(pathTl, paint);

    // 2. Top-Right Corner
    final pathTr = Path()
      ..moveTo(w - arm, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, arm);
    canvas.drawPath(pathTr, paint);

    // 3. Bottom-Right Corner
    final pathBr = Path()
      ..moveTo(w, h - arm)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(w - arm, h);
    canvas.drawPath(pathBr, paint);

    // 4. Bottom-Left Corner
    final pathBl = Path()
      ..moveTo(arm, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, h - arm);
    canvas.drawPath(pathBl, paint);
  }

  @override
  bool shouldRepaint(covariant _QrCornerPainter oldDelegate) {
    return oldDelegate.cornerColor != cornerColor ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
