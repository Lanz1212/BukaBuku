import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// 5-Step Payment Guide Card matching the Stitch UI design.
class QrisGuideAccordion extends StatelessWidget {
  final String merchantName;
  final String formattedAmount;

  const QrisGuideAccordion({
    super.key,
    this.merchantName = 'Toko Buku Budi',
    this.formattedAmount = 'Rp181.000',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Panduan Pembayaran',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
              Text(
                '5 Langkah',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Step 1
          _buildStepRow(
            stepNumber: 1,
            textSpan: const TextSpan(
              text: 'Buka aplikasi m-Banking atau dompet digital favorit Anda.',
            ),
          ),

          const SizedBox(height: 12),

          // Step 2
          _buildStepRow(
            stepNumber: 2,
            textSpan: const TextSpan(
              children: [
                TextSpan(text: 'Pilih menu '),
                TextSpan(
                  text: 'Bayar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                TextSpan(text: ' atau menu '),
                TextSpan(
                  text: 'Pindai QRIS',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Step 3
          _buildStepRow(
            stepNumber: 3,
            textSpan: const TextSpan(
              text: 'Arahkan kamera ke layar atau unggah gambar QR yang tersimpan.',
            ),
          ),

          const SizedBox(height: 12),

          // Step 4
          _buildStepRow(
            stepNumber: 4,
            textSpan: TextSpan(
              children: [
                const TextSpan(text: 'Pastikan nama penerima adalah '),
                TextSpan(
                  text: merchantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' dan nominal '),
                TextSpan(
                  text: formattedAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Step 5
          _buildStepRow(
            stepNumber: 5,
            textSpan: const TextSpan(
              text: 'Masukkan PIN transaksi Anda untuk menyelesaikan pesanan.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required int stepNumber,
    required InlineSpan textSpan,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.35,
              ),
              children: [textSpan],
            ),
          ),
        ),
      ],
    );
  }
}
