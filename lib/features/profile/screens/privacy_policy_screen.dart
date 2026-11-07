import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BookstoreAppBar(
        title: 'Syarat & Kebijakan Privasi',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primaryContainer,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Perlindungan Data & Layanan',
                                style: AppTypography.titleMd.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Terakhir Diperbarui: November 2026',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.outline,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selamat datang di Buka Buku. Halaman ini mengatur ketentuan penggunaan aplikasi dan bagaimana kami mengumpulkan, menggunakan, serta melindungi data pribadi Anda saat bertransaksi.',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 1
              _buildClauseCard(
                number: '1',
                title: 'Ketentuan Akun & Pendaftaran',
                paragraphs: [
                  'Pengguna wajib memberikan data yang akurat saat mendaftar akun di Buka Buku, termasuk nama lengkap, alamat email aktif, dan nomor telepon yang dapat dihubungi.',
                  'Pengguna bertanggung jawab menjaga kerahasiaan kredensial login (kata sandi) akun masing-masing. Buka Buku tidak bertanggung jawab atas kerugian yang diakibatkan oleh kelalaian pengguna dalam menjaga akses akun.',
                ],
              ),
              const SizedBox(height: 14),

              // Section 2
              _buildClauseCard(
                number: '2',
                title: 'Pemesanan & Pembayaran',
                paragraphs: [
                  'Seluruh harga buku yang tertera di aplikasi sudah termasuk pajak yang berlaku dan disajikan dalam mata uang Rupiah (IDR).',
                  'Pembayaran via QRIS harus diselesaikan sebelum batas waktu yang tertera pada layar hitung mundur pembayaran pesanan.',
                  'Pesanan yang tidak diselesaikan pembayarannya dalam batas waktu tersebut akan dibatalkan secara otomatis oleh sistem untuk membebaskan kuota stok buku bagi pembaca lain.',
                ],
              ),
              const SizedBox(height: 14),

              // Section 3
              _buildClauseCard(
                number: '3',
                title: 'Pengiriman & Pengambilan di Gerai',
                paragraphs: [
                  'Untuk pesanan pengiriman kurir, estimasi waktu tiba bergantung pada jarak alamat tujuan serta operasional mitra ekspedisi.',
                  'Untuk opsi Ambil di Toko (Store Pick-up), pengguna wajib menunjukkan QR Code yang sah kepada kasir saat mengambil buku di gerai Cikini.',
                  'Pesanan simpanan toko memiliki batas waktu simpan 5 hari kalender sebelum tim kami mengonfirmasi pembatalan atau perpanjangan waktu simpan.',
                ],
              ),
              const SizedBox(height: 14),

              // Section 4
              _buildClauseCard(
                number: '4',
                title: 'Kebijakan Privasi & Keamanan Data',
                paragraphs: [
                  'Kami tidak pernah menjual, menyewakan, atau membagikan data pribadi Anda (nama, nomor telepon, alamat, riwayat pesanan) kepada pihak ketiga di luar keperluan pengiriman barang.',
                  'Data alamat dan profil disimpan secara aman menggunakan protokol enkripsi standar industri.',
                  'Anda memiliki hak penuh untuk memperbarui, mengubah, atau meminta penghapusan riwayat data akun Anda kapan saja melalui kontak layanan pelanggan kami.',
                ],
              ),
              const SizedBox(height: 14),

              // Section 5
              _buildClauseCard(
                number: '5',
                title: 'Jaminan Buku & Retur',
                paragraphs: [
                  'Apabila buku yang diterima cacat produksi (halaman robek/kosong/salah cetak dari penerbit), kami memberikan garansi penggantian 100% tanpa biaya tambahan.',
                  'Klaim dapat diajukan maksimal 3 hari kerja setelah buku diterima dengan menyertakan bukti foto atau video kondisi fisik buku kepada customer care.',
                ],
              ),
              const SizedBox(height: 24),

              // Agreement Footer Note
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dengan terus menggunakan aplikasi Buka Buku, Anda menyetujui seluruh ketentuan layanan dan kebijakan privasi di atas.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClauseCard({
    required String number,
    required String title,
    required List<String> paragraphs,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < paragraphs.length; i++) ...[
            Text(
              paragraphs[i],
              style: AppTypography.bodyMd.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (i < paragraphs.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

