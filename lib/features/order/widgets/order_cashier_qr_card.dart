import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Cashier QR Code ticket display card.
/// Renders an authentic, scannable bookstore QR token for in-store pickup orders.
class OrderCashierQrCard extends StatelessWidget {
  final String qrCodeText;
  final String cashierInstructions;
  final VoidCallback? onTap;

  const OrderCashierQrCard({
    super.key,
    this.qrCodeText = 'ORD00125',
    this.cashierInstructions =
        'Tunjukkan QR Code ini kepada kasir saat mengambil pesanan',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPayload = qrCodeText.replaceAll('#', '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'SCAN QR CODE DI KASIR TOKO',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Real Scannable QR Code Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: 140,
              height: 140,
              child: QrImageView(
                data: cleanPayload.isEmpty ? 'ORD00125' : cleanPayload,
                version: QrVersions.auto,
                size: 140,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.primary,
                ),
                errorStateBuilder: (ctx, err) {
                  return const Center(
                    child: Text(
                      'Gagal memuat QR',
                      style: TextStyle(fontSize: 11, color: AppColors.error),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Monospace Code Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrCodeText,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

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
