import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Pesanan',
    'Pembayaran',
    'Pengambilan',
    'Akun',
  ];

  final List<_FaqItem> _allFaqs = const [
    _FaqItem(
      category: 'Pesanan',
      question: 'Bagaimana cara melacak pesanan buku saya?',
      answer:
          'Anda dapat melacak status pesanan melalui menu "Pesanan Saya" di halaman profil. Setiap perubahan status (Menunggu Pembayaran, Sedang Diproses, Siap Diambil/Dikirim, Selesai) akan otomatis diperbarui dan disertai notifikasi di aplikasi.',
    ),
    _FaqItem(
      category: 'Pesanan',
      question: 'Berapa lama estimasi pengiriman paket buku?',
      answer:
          'Untuk wilayah Jabodetabek, pengiriman reguler memakan waktu 1–2 hari kerja. Di luar Jabodetabek, pengiriman berkisar antara 2–4 hari kerja tergantung jarak dan ekspedisi yang dipilih.',
    ),
    _FaqItem(
      category: 'Pembayaran',
      question: 'Metode pembayaran apa saja yang didukung?',
      answer:
          'Buka Buku mendukung pembayaran instan via QRIS (BCA, Mandiri, GoPay, OVO, Dana, ShopeePay), Transfer Bank Virtual Account, serta Tunai di Kasir saat mengambil pesanan langsung di gerai toko.',
    ),
    _FaqItem(
      category: 'Pembayaran',
      question: 'Apakah pembayaran dengan QRIS diverifikasi otomatis?',
      answer:
          'Ya, sistem QRIS Buka Buku terhubung langsung secara real-time. Setelah Anda menyelesaikan transfer di aplikasi perbankan atau e-wallet, status pesanan otomatis berubah menjadi "Diproses" dalam beberapa detik.',
    ),
    _FaqItem(
      category: 'Pengambilan',
      question: 'Bagaimana prosedur ambil buku di gerai toko (Store Pick-up)?',
      answer:
          'Setelah pesanan berstatus "Siap Diambil", buka detail pesanan di aplikasi dan tunjukkan Kode QR Pengambilan kepada kasir/staf gerai Buka Buku Cikini. Kasir akan memindai QR dan menyerahkan paket buku Anda.',
    ),
    _FaqItem(
      category: 'Pengambilan',
      question: 'Berapa batas waktu pengambilan pesanan di toko?',
      answer:
          'Pesanan yang siap diambil dapat disimpan di loker gerai kami hingga maksimal 5 hari kalender sejak status berubah menjadi "Siap Diambil".',
    ),
    _FaqItem(
      category: 'Akun',
      question: 'Bagaimana cara mengubah alamat pengiriman saya?',
      answer:
          'Buka menu "Alamat Pengiriman" di halaman profil Anda. Anda dapat menambah alamat baru, menetapkan alamat utama, mengedit detail alamat, atau menghapus alamat yang sudah tidak digunakan.',
    ),
    _FaqItem(
      category: 'Akun',
      question: 'Apakah buku yang dijual dijamin 100% original?',
      answer:
          'Seluruh koleksi buku di Buka Buku dijamin 100% original langsung dari penerbit resmi nasional dan internasional. Kami menjamin keaslian buku dan integritas cetakan.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItem> get _filteredFaqs {
    return _allFaqs.where((faq) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$label berhasil disalin!'),
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
    final faqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BookstoreAppBar(
        title: 'Pusat Bantuan',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ada yang bisa kami bantu?',
                            style: AppTypography.titleMd.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Temukan jawaban cepat seputar pemesanan, pembayaran, atau hubungi customer care kami.',
                      style: AppTypography.bodyMd.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan (misal: QRIS, ongkir)...',
                  hintStyle: AppTypography.caption.copyWith(
                    color: AppColors.outline,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.outline,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
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
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
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
              const SizedBox(height: 14),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        backgroundColor: AppColors.surfaceContainerLowest,
                        labelStyle: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white : AppColors.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : AppColors.outlineVariant.withValues(alpha: 0.6),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // FAQ Section Header
              Text(
                'Pertanyaan Populer (${faqs.length})',
                style: AppTypography.titleMd.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),

              // FAQ List
              if (faqs.isEmpty)
                Material(
                  color: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: AppColors.outline,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ditemukan jawaban untuk "$_searchQuery"',
                          style: AppTypography.titleMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba kata kunci lain atau hubungi customer service kami di bawah.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...faqs.map(
                  (faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: AppColors.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          childrenPadding: const EdgeInsets.only(
                            left: 14,
                            right: 14,
                            bottom: 14,
                          ),
                          leading: const Icon(
                            Icons.help_outline_rounded,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                          title: Text(
                            faq.question,
                            style: AppTypography.titleMd.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          children: [
                            Text(
                              faq.answer,
                              style: AppTypography.bodyMd.copyWith(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Contact Customer Care Section
              Text(
                'Kontak Layanan Pelanggan',
                style: AppTypography.titleMd.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 10),

              Material(
                color: AppColors.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'WhatsApp Buka Buku Care',
                        style: AppTypography.titleMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '+62 812-3456-7890 (Respon Cepat)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        color: AppColors.outline,
                        tooltip: 'Salin Nomor WhatsApp',
                        onPressed: () => _copyToClipboard(
                          '+6281234567890',
                          'Nomor WhatsApp Buka Buku Care',
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.primaryContainer,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Email Dukungan',
                        style: AppTypography.titleMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'halo@bukabuku.id',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        color: AppColors.outline,
                        tooltip: 'Salin Email',
                        onPressed: () => _copyToClipboard(
                          'halo@bukabuku.id',
                          'Alamat Email Dukungan',
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 16,
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 18,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Jam Operasional CS: Setiap Hari (08:00 – 21:00 WIB)',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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
}

class _FaqItem {
  final String category;
  final String question;
  final String answer;

  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
