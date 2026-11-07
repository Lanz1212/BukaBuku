import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyAddress(BuildContext context) {
    const address =
        'Toko Buku Budi Gerai Cikini, Jl. Cikini Raya No. 10, RT 01 / RW 02, Menteng, Jakarta Pusat, DKI Jakarta 10330';
    Clipboard.setData(const ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Alamat gerai toko berhasil disalin!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BookstoreAppBar(
        title: 'Tentang Buka Buku',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Brand Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 38,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Buka Buku',
                      style: AppTypography.headlineSm.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Menemani Pembaca Indonesia Sejak 1982',
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Versi Aplikasi 1.0.0 (Production)',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Kisah Kami
              _buildSectionCard(
                title: 'Kisah Kami',
                icon: Icons.history_edu_rounded,
                content:
                    'Buka Buku berawal dari sebuah toko buku kecil di kawasan Cikini, Jakarta Pusat pada tahun 1982. Didirikan oleh Budi Santoso dengan kecintaan mendalam terhadap literatur dan ilmu pengetahuan, toko ini telah menjadi tempat berkumpulnya para pecinta buku, akademisi, sastrawan, dan generasi pembaca muda dari masa ke masa.\n\nKini, melalui aplikasi mobile Buka Buku, kami menghadirkan kemudahan menjelajahi ribuan judul pilihan kurasi terbaik langsung dari genggaman Anda—dengan tetap mempertahankan kehangatan layanan toko buku fisik kami.',
              ),
              const SizedBox(height: 16),

              // Komitmen & Nilai Kami
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Komitmen Kami',
                          style: AppTypography.titleMd.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildValueRow(
                      icon: Icons.check_circle_outline_rounded,
                      title: '100% Buku Asli & Bergaransi',
                      subtitle:
                          'Hanya menyediakan buku original berlisensi dari penerbit terpercaya.',
                    ),
                    const SizedBox(height: 10),
                    _buildValueRow(
                      icon: Icons.local_shipping_outlined,
                      title: 'Kemasan Buku Ekstra Aman',
                      subtitle:
                          'Dilapisi bubble wrap tebal dan kardus khusus agar buku tiba dalam kondisi prima.',
                    ),
                    const SizedBox(height: 10),
                    _buildValueRow(
                      icon: Icons.storefront_rounded,
                      title: 'Layanan Pengambilan Cepat di Toko',
                      subtitle:
                          'Pesan lewat aplikasi, ambil langsung di gerai tanpa antre kasir.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Gerai Utama Kami
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gerai Utama Buka Buku',
                              style: AppTypography.titleMd.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => _copyAddress(context),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text('Salin Alamat'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryContainer,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            textStyle: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Jl. Cikini Raya No. 10, RT 01 / RW 02, Menteng, Jakarta Pusat, DKI Jakarta 10330',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buka Setiap Hari: 08:00 – 21:00 WIB',
                          style: AppTypography.caption.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Footer
              Center(
                child: Text(
                  '© 1982–2026 PT Toko Buku Budi Indonesia\nSeluruh Hak Cipta Dilindungi Undang-Undang',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.outline,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.titleMd.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.success),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMd.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

