import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final rawText = _controller.text.trim();
    if (rawText.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan nomor pesanan terlebih dahulu';
      });
      return;
    }

    final formattedId = rawText.toUpperCase().startsWith('#')
        ? rawText.toUpperCase()
        : '#${rawText.toUpperCase()}';

    // Mock look up
    if (formattedId == '#ORD00125') {
      Navigator.pop(context);
      widget.onOrderFound(QrScanResult.mockDefault());
    } else {
      // Demo fallback mock for any other valid order input
      Navigator.pop(context);
      widget.onOrderFound(
        QrScanResult(
          orderId: formattedId,
          customerName: 'Pelanggan Kasir',
          bookCount: 1,
          totalPrice: 85000,
          status: 'Siap Diambil',
          verificationTime: '0.2s',
        ),
      );
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

          // Quick selection suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Saran Cepat:',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              InkWell(
                onTap: () {
                  _controller.text = 'ORD00125';
                  setState(() => _errorMessage = null);
                },
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECDA),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '#ORD00125 (Budi Santoso)',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFB5702F),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
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
            onPressed: _submit,
            child: Text(
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
