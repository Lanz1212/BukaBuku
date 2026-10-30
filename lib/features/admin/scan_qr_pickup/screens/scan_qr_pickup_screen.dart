import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../order_management/models/admin_order_detail.dart';
import '../models/qr_scan_result.dart';
import '../widgets/manual_order_input_sheet.dart';
import '../widgets/qr_action_buttons.dart';
import '../widgets/qr_detection_card.dart';
import '../widgets/qr_mode_banner.dart';
import '../widgets/qr_viewfinder_widget.dart';
import 'qr_scan_result_screen.dart';

class ScanQrPickupScreen extends StatefulWidget {
  final AdminOrderDetail? preloadedOrder;

  const ScanQrPickupScreen({
    super.key,
    this.preloadedOrder,
  });

  @override
  State<ScanQrPickupScreen> createState() => _ScanQrPickupScreenState();
}

class _ScanQrPickupScreenState extends State<ScanQrPickupScreen> {
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  QrScanResult? _detectedResult;

  @override
  void initState() {
    super.initState();
    // Pre-populate with order from detail or default mock to match the design screenshot
    if (widget.preloadedOrder != null) {
      _detectedResult = QrScanResult.fromOrder(widget.preloadedOrder!);
    } else {
      _detectedResult = QrScanResult.mockDefault();
    }
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isTorchOn ? 'Senter scanner dinyalakan' : 'Senter scanner dimatikan',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFrontCamera
              ? 'Kamera dialihkan ke depan'
              : 'Kamera dialihkan ke belakang',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onViewfinderTapped() {
    // Interactive re-scan trigger
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memindai ulang QR Code...'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _detectedResult = widget.preloadedOrder != null
          ? QrScanResult.fromOrder(widget.preloadedOrder!)
          : QrScanResult.mockDefault();
    });
  }

  void _openManualInput() {
    ManualOrderInputSheet.show(
      context,
      onOrderFound: (result) {
        setState(() {
          _detectedResult = result;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pesanan ${result.orderId} berhasil ditemukan!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _handleValidationComplete() async {
    if (_detectedResult == null) return;

    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => QrScanResultScreen(result: _detectedResult!),
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F5),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Scan Qr Pickup',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 18,
          ),
        ),
        actions: [
          // Staff Role Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE8E3),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 13,
                  color: Color(0xFF6B655F),
                ),
                const SizedBox(width: 4),
                Text(
                  'Staff',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF6B655F),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Torch Toggle Button
          IconButton(
            icon: Icon(
              _isTorchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_on_outlined,
              size: 21,
              color: _isTorchOn ? const Color(0xFFD99A35) : AppColors.onSurface,
            ),
            tooltip: 'Senter',
            onPressed: _toggleTorch,
          ),

          // Camera Switch Button
          IconButton(
            icon: const Icon(
              Icons.cameraswitch_outlined,
              size: 21,
              color: AppColors.onSurface,
            ),
            tooltip: 'Ganti Kamera',
            onPressed: _flipCamera,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Mode Kasir Banner
              const QrModeBanner(
                outletName: 'Gerai Cikini',
                isActive: true,
              ),

              // 2. Camera Viewfinder Area
              QrViewfinderWidget(
                isTorchOn: _isTorchOn,
                onScanTriggered: _onViewfinderTapped,
              ),
              const SizedBox(height: 18),

              // 3. Instruction Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 20,
                    color: AppColors.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Arahkan kamera ke QR Pickup',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Pastikan kode QR berada tepat di dalam bingkai bidik untuk proses verifikasi instan.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: const Color(0xFF737373),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Action Buttons (Senter + Input Manual)
              QrActionButtons(
                isTorchOn: _isTorchOn,
                onToggleTorch: _toggleTorch,
                onManualInput: _openManualInput,
              ),

              // 5. Detection Card
              if (_detectedResult != null)
                QrDetectionCard(
                  result: _detectedResult!,
                  onValidatePressed: _handleValidationComplete,
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
