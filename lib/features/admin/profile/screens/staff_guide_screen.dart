import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Screen Panduan Staf & Bantuan Admin Buka Buku
/// Menyediakan SOP operasional, alur transaksi kasir, & bantuan teknis toko secara statis.
class StaffGuideScreen extends StatefulWidget {
  const StaffGuideScreen({super.key});

  @override
  State<StaffGuideScreen> createState() => _StaffGuideScreenState();
}

class _StaffGuideScreenState extends State<StaffGuideScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_GuideCategory> _allCategories = [
    _GuideCategory(
      title: 'SOP Operasional & Kasir',
      icon: Icons.storefront_rounded,
      color: const Color(0xFF2E7D32),
      items: [
        _GuideItem(
          title: 'Pembukaan Shift Kasir',
          steps: [
            'Nyalakan perangkat terminal kasir dan login menggunakan akun staf aktif.',
            'Hitung uang modal kasir (uang pecahan kecil) di laci kas dan pastikan nominal sesuai pencatatan.',
            'Periksa koneksi internet / Wi-Fi toko agar sinkronisasi Cloud pesanan tetap real-time.',
            'Cek stok kertas printer resi atau daya baterai scanner Bluetooth (bila digunakan).',
          ],
        ),
        _GuideItem(
          title: 'Penutupan Shift & Rekonsiliasi Kas',
          steps: [
            'Hentikan penerimaan antrean transaksi baru 15 menit sebelum jam operasional tutup.',
            'Hitung total uang fisik tunai di laci kasir dan bandingkan dengan rekap sistem pada tab Pembayaran.',
            'Cetak atau simpan ringkasan transaksi shift Anda.',
            'Serahkan laci kas dalam keadaan terkunci dan kunci diserahkan kepada supervisor shift berikutnya.',
          ],
        ),
        _GuideItem(
          title: 'Pelayanan Ramah Pelanggan (Hospitality SOP)',
          steps: [
            'Sambut pelanggan yang masuk ke toko dengan salam ramah ("Selamat datang di Buka Buku").',
            'Bantu pembeli menemukan letak rak buku berdasarkan kategori atau nomor rak.',
            'Tawarkan kemasan ramah lingkungan (totebag) atau sampul plastik gratis bila ada promosi berjalan.',
          ],
        ),
      ],
    ),
    _GuideCategory(
      title: 'Alur Pesanan & QR Pickup',
      icon: Icons.qr_code_scanner_rounded,
      color: AppColors.primaryContainer,
      items: [
        _GuideItem(
          title: 'Menerima Pesanan Masuk (Pickup / Kurir)',
          steps: [
            'Periksa tab Manajemen Pesanan secara berkala untuk notifikasi pesanan "Baru".',
            'Ambil buku fisik dari rak pajang atau gudang sesuai judul, penerbit, dan edisi.',
            'Pastikan fisik buku bersih, tidak berdebu, tidak sobek, dan barcode utuh.',
            'Ubah status pesanan menjadi "Diproses" lalu "Siap Diambil" atau "Siap Dikirim".',
          ],
        ),
        _GuideItem(
          title: 'Validasi QR Pickup Pembeli',
          steps: [
            'Minta pembeli menunjukkan layar QR Pickup di aplikasi Buka Buku mereka.',
            'Buka fitur Scan QR Pickup di menu admin dan arahkan kamera ke kode QR pelanggan.',
            'Sistem akan memverifikasi keabsahan kode dan mencocokkan data buku secara otomatis.',
            'Jika status pembayaran sudah LUNAS, langsung serahkan buku kepada pembeli.',
            'Jika pembeli memilih opsi "Bayar di Kasir", terima pembayaran tunai terlebih dahulu lalu klik tombol Konfirmasi.',
          ],
        ),
        _GuideItem(
          title: 'Penanganan QR Bermasalah / Batal',
          steps: [
            'Jika QR tidak terbaca kamera scanner, gunakan fitur "Input Manual ID Pesanan" di pojok kanan atas layar scan.',
            'Jika pesanan berstatus Dibatalkan atau Kedaluwarsa, jelaskan kepada pembeli secara sopan agar memesan ulang lewat aplikasi.',
          ],
        ),
      ],
    ),
    _GuideCategory(
      title: 'Manajemen Inventaris & Stok',
      icon: Icons.inventory_2_outlined,
      color: const Color(0xFFD97706),
      items: [
        _GuideItem(
          title: 'Penyesuaian Stok Fisik vs Sistem',
          steps: [
            'Buka menu Manajemen Buku / Manajemen Stok di panel admin.',
            'Gunakan tombol penyesuaian cepat (+ / -) jika terjadi selisih stok fisik.',
            'Setiap pengurangan stok manual (misal buku rusak/retur) wajib mencantumkan alasan di catatan.',
          ],
        ),
        _GuideItem(
          title: 'Buku Stok Menipis (Low Stock Alert)',
          steps: [
            'Buku dengan stok <= 3 eksemplar akan memicu lencana peringatan kuning.',
            'Laporkan ke manajer toko atau bagian pengadaan untuk pesanan restock penerbit.',
          ],
        ),
      ],
    ),
    _GuideCategory(
      title: 'Bantuan Teknis & Kontak Darurat',
      icon: Icons.support_agent_rounded,
      color: const Color(0xFF2563EB),
      items: [
        _GuideItem(
          title: 'Kontak Tim IT & Dukungan Toko',
          steps: [
            'WhatsApp Helpdesk IT: 0812-3456-7890 (Setiap Hari 08:00 - 22:00 WIB)',
            'Email Dukungan: support@bukabuku.id',
            'Alamat Toko: Jl. Cikini Raya No. 45, Menteng, Jakarta Pusat',
          ],
        ),
        _GuideItem(
          title: 'Troubleshooting Aplikasi Macet / Offline',
          steps: [
            'Periksa lampu indikator router toko. Jika internet mati, hubungi provider.',
            'Tutup aplikasi Buka Buku sepenuhnya dari task manager, lalu buka kembali.',
            'Pastikan versi aplikasi telah diperbarui ke rilis stabil terbaru.',
          ],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredCategories = _allCategories.map((cat) {
      if (query.isEmpty) return cat;
      final matchedItems = cat.items.where((item) {
        final matchTitle = item.title.toLowerCase().contains(query);
        final matchSteps = item.steps.any((s) => s.toLowerCase().contains(query));
        return matchTitle || matchSteps;
      }).toList();
      return _GuideCategory(
        title: cat.title,
        icon: cat.icon,
        color: cat.color,
        items: matchedItems,
      );
    }).where((cat) => cat.items.isNotEmpty).toList();

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
        title: Text(
          'Panduan Staf & Bantuan',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 17,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Pengantar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2C2218),
                    Color(0xFF4A3B2C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFFFBF9F5),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buku Pedoman Kasir & Toko',
                          style: AppTypography.titleMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Standar Operasional Prosedur (SOP) harian staf kasir dan operasional Buka Buku.',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFFD4C9BD),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari panduan SOP (misal: shift, QR, stok)...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outlineVariant,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Accordion List / Guide Sections
            if (filteredCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tidak ada panduan yang cocok',
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredCategories.map((category) {
                return _buildCategorySection(category);
              }),

            const SizedBox(height: 12),

            // Help Callout Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3ECE1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2D4C3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.headset_mic_rounded,
                    color: Color(0xFF8C5C33),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Butuh Bantuan Mendesak?',
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5A3B20),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hubungi supervisor jaga di WhatsApp Toko atau PIC operasional bila menemukan kendala sistem.',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF755C47),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(_GuideCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          title: Text(
            category.title,
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
              color: AppColors.onSurface,
            ),
          ),
          subtitle: Text(
            '${category.items.length} SOP & Petunjuk',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.5,
            ),
          ),
          children: category.items.map((item) {
            return _buildItemCard(item, category.color);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItemCard(_GuideItem item, Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...item.steps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final text = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: AppTypography.caption.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _GuideCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<_GuideItem> items;

  const _GuideCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class _GuideItem {
  final String title;
  final List<String> steps;

  const _GuideItem({
    required this.title,
    required this.steps,
  });
}

