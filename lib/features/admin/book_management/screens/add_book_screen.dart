import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/admin_book_item.dart';
import '../widgets/book_form_cover_upload.dart';

class AddBookScreen extends StatefulWidget {
  final AdminBookItem? initialBook;

  const AddBookScreen({
    super.key,
    this.initialBook,
  });

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _publisherController;
  late final TextEditingController _yearController;
  late final TextEditingController _isbnController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _rackController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory;
  String? _coverUrl;
  int _charCount = 0;

  final List<String> _categories = const [
    'Pengembangan Diri',
    'Novel & Sastra',
    'Non-Fiksi',
    'Komik & Grafis',
    'Bisnis & Finansial',
    'Filsafat & Pemikiran',
    'Sejarah & Budaya',
    'Buku Anak',
    'Pendidikan',
  ];

  final List<String> _presetCovers = const [
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&q=80&w=400',
    'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?auto=format&fit=crop&q=80&w=400',
  ];

  @override
  void initState() {
    super.initState();
    final book = widget.initialBook;

    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _publisherController = TextEditingController(text: book?.publisher ?? '');
    _yearController = TextEditingController(
      text: book?.publishYear != null ? '${book!.publishYear}' : '2024',
    );
    _isbnController = TextEditingController(text: book?.isbn ?? '');
    _priceController = TextEditingController(
      text: book != null ? '${book.price}' : '',
    );
    _stockController = TextEditingController(
      text: book != null ? '${book.stock}' : '',
    );
    _rackController = TextEditingController(text: book?.rackLocation ?? '');
    _descriptionController =
        TextEditingController(text: book?.description ?? '');

    _coverUrl = book?.coverUrl;
    _charCount = _descriptionController.text.length;

    if (book != null) {
      if (_categories.contains(book.category)) {
        _selectedCategory = book.category;
      } else if (book.category == 'Novel') {
        _selectedCategory = 'Novel & Sastra';
      } else {
        _selectedCategory = 'Pengembangan Diri';
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _rackController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openCoverPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Contoh Foto Cover',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih salah satu template sampul buku untuk simulasi',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presetCovers.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final url = _presetCovers[idx];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _coverUrl = url;
                        });
                        Navigator.pop(ctx);
                        _showNotice('Cover buku terpilih');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 120,
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBook() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final priceText = _priceController.text.trim().replaceAll('.', '');
    final stockText = _stockController.text.trim();

    if (title.isEmpty) {
      _showNotice('Judul buku wajib diisi');
      return;
    }
    if (author.isEmpty) {
      _showNotice('Nama penulis wajib diisi');
      return;
    }
    if (_selectedCategory == null) {
      _showNotice('Silakan pilih kategori buku');
      return;
    }
    final price = int.tryParse(priceText);
    if (price == null || price <= 0) {
      _showNotice('Harga jual tidak valid');
      return;
    }
    final stock = int.tryParse(stockText);
    if (stock == null || stock < 0) {
      _showNotice('Stok awal tidak valid');
      return;
    }

    final isbn = _isbnController.text.trim().isEmpty
        ? '978-602-00-0000-0'
        : _isbnController.text.trim();
    final rack = _rackController.text.trim().isEmpty
        ? 'A-01'
        : _rackController.text.trim();

    AdminBookStatus status;
    if (stock == 0) {
      status = AdminBookStatus.outOfStock;
    } else if (stock <= 3) {
      status = AdminBookStatus.menipis;
    } else {
      status = AdminBookStatus.tersedia;
    }

    final savedBook = AdminBookItem(
      id: widget.initialBook?.id ??
          'B${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      title: title,
      author: author,
      isbn: isbn,
      price: price,
      stock: stock,
      rackLocation: rack,
      status: status,
      isActive: widget.initialBook?.isActive ?? true,
      category: _selectedCategory!,
      publisher: _publisherController.text.trim(),
      publishYear: int.tryParse(_yearController.text.trim()) ?? 2024,
      description: _descriptionController.text.trim(),
      coverUrl: _coverUrl ?? _presetCovers[0],
    );

    Navigator.pop(context, savedBook);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.initialBook != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(isEditing),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Editorial Helper Tip
                    _buildEditorialTip(),
                    const SizedBox(height: 18),

                    // Section 1: Upload Cover
                    BookFormCoverUpload(
                      coverUrl: _coverUrl,
                      onPickCover: _openCoverPicker,
                      onRemoveCover: () {
                        setState(() {
                          _coverUrl = null;
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Section 2: Informasi Utama Buku
                    _buildMainInfoSection(),
                    const SizedBox(height: 18),

                    // Section 3: Harga & Inventaris Rak
                    _buildInventorySection(),
                    const SizedBox(height: 18),

                    // Section 4: Deskripsi & Sinopsis
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Bar
            _buildBottomActionBar(isEditing),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEditing) {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.onSurface,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Image.asset(
            'assets/images/Logo Toko Buku Budi.png',
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.book_rounded,
              size: 24,
              color: AppColors.primaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isEditing ? 'Ubah Data Buku' : 'Tambah Buku',
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.onPrimary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorialTip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Katalog Toko Budi',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSecondaryContainer,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lengkapi detail buku untuk memastikan kurasi rak dan pencarian pembaca akurat di sistem kasir dan etalase digital.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11.5,
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

  Widget _buildMainInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informasi Utama Buku',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Judul Buku *
          _buildFieldLabel('Judul Buku', isRequired: true),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _titleController,
            hintText: 'cth: Atomic Habits',
          ),
          const SizedBox(height: 14),

          // Penulis *
          _buildFieldLabel('Penulis', isRequired: true),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _authorController,
            hintText: 'cth: James Clear',
          ),
          const SizedBox(height: 14),

          // Penerbit
          _buildFieldLabel('Penerbit'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _publisherController,
            hintText: 'cth: Gramedia Pustaka Utama',
          ),
          const SizedBox(height: 14),

          // 2 Columns: Tahun Terbit & Kategori
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Tahun Terbit'),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _yearController,
                      hintText: '2023',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Kategori', isRequired: true),
                    const SizedBox(height: 6),
                    _buildCategoryDropdown(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ISBN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('ISBN'),
              Text(
                '13 Digit Standar',
                style: AppTypography.caption.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _isbnController,
            hintText: 'cth: 978-602-06-3317-6',
            prefixIcon: const Icon(
              Icons.view_column_rounded,
              color: AppColors.outline,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Harga & Inventaris Rak',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2 Columns: Harga Jual & Stok Awal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Harga Jual (Rp)', isRequired: true),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _priceController,
                      hintText: '85.000',
                      keyboardType: TextInputType.number,
                      prefixWidget: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 6),
                        child: Text(
                          'Rp',
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Stok Awal', isRequired: true),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _stockController,
                      hintText: '10',
                      keyboardType: TextInputType.number,
                      suffixWidget: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: Text(
                          'Eks',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Lokasi Rak Toko
          _buildFieldLabel('Lokasi Rak Toko'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _rackController,
            hintText: 'cth: Rak A3 - Utama Cikini',
            prefixIcon: const Icon(
              Icons.table_restaurant_outlined,
              color: AppColors.outline,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Memudahkan staf fisik menemukan buku saat order online masuk.',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header + Character Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.subject_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Deskripsi & Sinopsis',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                '$_charCount/1000',
                style: AppTypography.caption.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Textarea
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 1000,
              onChanged: (val) {
                setState(() {
                  _charCount = val.length;
                });
              },
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                height: 1.45,
              ),
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
              decoration: InputDecoration(
                hintText:
                    'Tuliskan sinopsis singkat, kutipan memikat, dan keunggulan buku untuk pembaca Toko Buku Budi...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outline,
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Batal Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              foregroundColor: AppColors.primary,
              elevation: 0,
              fixedSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text(
              'Batal',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Simpan Buku Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                elevation: 2,
                fixedSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(
                isEditing ? 'Perbarui Buku' : 'Simpan Buku',
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTypography.labelMd.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 12.5,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Widget? prefixWidget,
    Widget? suffixWidget,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ?prefixWidget,
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: prefixIcon,
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.outline,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixIcon == null && prefixWidget == null ? 14 : 4,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          ?suffixWidget,
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: Text(
            'Pilih Kategori',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.outline,
              fontSize: 13,
            ),
          ),
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.outline,
          ),
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurface,
          ),
          dropdownColor: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          items: _categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(
                cat,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
            });
          },
        ),
      ),
    );
  }
}
