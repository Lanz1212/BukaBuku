import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'scan_scenario_tabs.dart';

class QrPaymentStatusBanner extends StatelessWidget {
  final ScanScenario scenario;
  final String formattedTotal;

  const QrPaymentStatusBanner({
    super.key,
    required this.scenario,
    required this.formattedTotal,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String title;
    String description;

    switch (scenario) {
      case ScanScenario.validOnline:
        bgColor = const Color(0xFFEBF7F0);
        borderColor = AppColors.success.withValues(alpha: 0.35);
        iconColor = AppColors.success;
        iconData = Icons.check_circle_rounded;
        title = 'Lunas via QRIS (Online)';
        description =
            'Pembayaran telah diverifikasi otomatis oleh payment gateway. Tidak perlu menagih tunai ke pelanggan.';
        break;
      case ScanScenario.validCash:
        bgColor = const Color(0xFFFEF6EC);
        borderColor = AppColors.warning.withValues(alpha: 0.35);
        iconColor = AppColors.warning;
        iconData = Icons.payments_rounded;
        title = 'Tagihan Kasir: $formattedTotal';
        description =
            'Pelanggan memilih Bayar di Tempat. Pastikan menerima uang tunai pas atau kembalian sebelum menyerahkan buku.';
        break;
      case ScanScenario.invalidQr:
        bgColor = AppColors.errorContainer.withValues(alpha: 0.35);
        borderColor = AppColors.error.withValues(alpha: 0.35);
        iconColor = AppColors.error;
        iconData = Icons.cancel_rounded;
        title = 'Status Tidak Valid / Dibatalkan';
        description =
            'Transaksi ini tidak dapat dilanjutkan karena pesanan berstatus dibatalkan atau QR kedaluwarsa.';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
