import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// State 2: Success view when QRIS payment is confirmed
class QrisSuccessView extends StatelessWidget {
  final int totalAmount;
  final VoidCallback onBackToHome;
  final VoidCallback onViewReceipt;

  const QrisSuccessView({
    super.key,
    required this.totalAmount,
    required this.onBackToHome,
    required this.onViewReceipt,
  });

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Green Laurel Success Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF3F8F5F).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 44,
              color: Color(0xFF3F8F5F),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Pembayaran Berhasil!',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dana telah diterima dan dikonfirmasi otomatis oleh sistem perbankan.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Receipt Breakdown Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _buildReceiptRow('Waktu Bayar', 'Hari ini, 15:42 WIB'),
                const Divider(height: 18, color: AppColors.outlineVariant),
                _buildReceiptRow('ID Referensi', 'TRX-99482103B', isMono: true),
                const Divider(height: 18, color: AppColors.outlineVariant),
                _buildReceiptRow(
                  'Jumlah Dibayar',
                  _formatRupiah(totalAmount),
                  isBoldPrimary: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Packaging thematic notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pesanan Anda segera dikemas rapi dengan pembatas buku tematik dari Cikini.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary Button: Lihat Struk
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onViewReceipt,
              icon: const Icon(Icons.receipt_long, size: 18, color: Colors.white),
              label: Text(
                'Lihat Struk Pesanan',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Secondary Text Button: Kembali ke Beranda
          TextButton(
            onPressed: onBackToHome,
            child: Text(
              'Kembali ke Beranda',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isMono = false,
    bool isBoldPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: isBoldPrimary
              ? AppTypography.titleMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                )
              : AppTypography.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: isMono ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: isMono ? 'monospace' : null,
                  fontSize: 13,
                ),
        ),
      ],
    );
  }
}

/// State 3: Failed view when QRIS payment fails or errors
class QrisFailedView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onSelectOtherMethod;

  const QrisFailedView({
    super.key,
    required this.onRetry,
    required this.onSelectOtherMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Terracotta Error Badge
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 44,
              color: AppColors.error,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Pembayaran Gagal',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sistem belum dapat memverifikasi transaksi Anda atau saldo tidak mencukupi.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Troubleshooting Tips Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan limit transaksi harian m-Banking Anda mencukupi.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan koneksi internet stabil saat melakukan otorisasi PIN.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary Button: Coba Bayar Ulang
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: Text(
                'Coba Bayar Ulang',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Secondary Text Button: Pilih Metode Lain
          TextButton(
            onPressed: onSelectOtherMethod,
            child: Text(
              'Pilih Metode Pembayaran Lain',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// State 4: Expired view when 15-minute window expires
class QrisExpiredView extends StatelessWidget {
  final VoidCallback onRefreshQR;
  final VoidCallback onBackToCart;

  const QrisExpiredView({
    super.key,
    required this.onRefreshQR,
    required this.onBackToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Hourglass Expired Badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_disabled_outlined,
              size: 44,
              color: AppColors.outline,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Kode QR Kedaluwarsa',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sesi pembayaran 15 menit telah berakhir untuk menjaga keamanan transaksi buku Anda.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Replay explanation box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.replay,
                  size: 22,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Klik tombol di bawah untuk menghasilkan kode QR baru dengan harga buku yang sama.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary Button: Perbarui Kode QR
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onRefreshQR,
              icon: const Icon(Icons.autorenew, size: 18, color: Colors.white),
              label: Text(
                'Perbarui Kode QR',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Secondary Text Button: Kembali ke Keranjang
          TextButton(
            onPressed: onBackToCart,
            child: Text(
              'Kembali ke Keranjang Belanja',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
