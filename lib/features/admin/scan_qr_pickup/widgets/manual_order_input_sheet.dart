import 'package:flutter/material.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/qr_scan_result.dart';

class ManualOrderInputSheet extends StatefulWidget {
  final ValueChanged<QrScanResult> onOrderFound;

  const ManualOrderInputSheet({
    super.key,
    required this.onOrderFound,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<QrScanResult> onOrderFound,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ManualOrderInputSheet(onOrderFound: onOrderFound),
    );
  }

  @override
  State<ManualOrderInputSheet> createState() => _ManualOrderInputSheetState();
}

class _ManualOrderInputSheetState extends State<ManualOrderInputSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final rawText = _controller.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan kode pesanan terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await OrderService.fetchOrderByCodeOrId(rawText);
      if (!mounted) return;

      if (order == null) {
        setState(() {
          _errorMessage =
              'Pesanan "$rawText" tidak ditemukan di sistem. Periksa kembali kode pesanan.';
        });
        return;
      }

      final isPickup = order.deliveryType.toLowerCase().contains('ambil');
      if (!isPickup) {
        setState(() {
          _errorMessage =
              'Pesanan ${order.orderId} adalah Kurir Antar (Bukan Ambil di Toko).';
        });
        return;
      }

      Navigator.pop(context);
      widget.onOrderFound(QrScanResult.fromOrder(order));
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan saat memeriksa pesanan: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.keyboard_alt_outlined,
                  color: AppColors.primaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Manual #ORD',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ketik nomor pesanan dari nota atau struk',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Input field
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            autofocus: true,
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: ORD00125',
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.outline,
                letterSpacing: 0,
              ),
              prefixIcon: const Icon(
                Icons.tag_rounded,
                color: AppColors.primaryContainer,
              ),
              errorText: _errorMessage,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryContainer,
                  width: 1.6,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),

          // Helper hint text
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 15,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Masukkan ID pesanan atau kode pickup yang tertera pada aplikasi pelanggan.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Cari & Verifikasi Pesanan',
                    style: AppTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
