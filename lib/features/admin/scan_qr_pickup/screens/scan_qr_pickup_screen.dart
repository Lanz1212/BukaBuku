import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/order_service.dart';
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
  late final MobileScannerController _scannerController;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _isProcessingScan = false;
  QrScanResult? _detectedResult;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode, BarcodeFormat.all],
    );

    if (widget.preloadedOrder != null) {
      _detectedResult = QrScanResult.fromOrder(widget.preloadedOrder!);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {}
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    if (!mounted) return;
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

  void _flipCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {}
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    if (!mounted) return;
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

  Future<void> _handleBarcodeDetected(String rawCode) async {
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    final cleanCode = rawCode.replaceAll('#', '').trim();
    if (cleanCode.isEmpty) {
      _isProcessingScan = false;
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final order = await OrderService.fetchOrderByCodeOrId(cleanCode);
      if (!mounted) return;

      if (order == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Pesanan "$cleanCode" tidak ditemukan di sistem!'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Validasi khusus pesanan Ambil di Toko
      final isPickup = order.deliveryType.toLowerCase().contains('ambil');
      if (!isPickup) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan ${order.orderId} adalah Kurir Antar (Bukan Ambil di Toko)!',
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final scanResult = QrScanResult.fromOrder(order);
      setState(() {
        _detectedResult = scanResult;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('QR Pesanan ${order.orderId} berhasil dipindai!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );

      final result = await navigator.push<dynamic>(
        MaterialPageRoute(
          builder: (context) => QrScanResultScreen(result: scanResult),
        ),
      );

      if (result != null && mounted) {
        navigator.pop(result);
      }
    } catch (e) {
      debugPrint('Error handling scanned barcode: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _isProcessingScan = false;
        }
      });
    }
  }

  void _onViewfinderTapped() {
    _openManualInput();
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
                outletName: 'Gerai Buka Buku',
                isActive: true,
              ),

              // 2. Camera Viewfinder Area
              QrViewfinderWidget(
                scannerController: _scannerController,
                onBarcodeScanned: _handleBarcodeDetected,
                isTorchOn: _isTorchOn,
                onScanTriggered: _onViewfinderTapped,
                onZoomChanged: (zoom) {
                  try {
                    _scannerController.setZoomScale(zoom);
                  } catch (_) {}
                },
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
