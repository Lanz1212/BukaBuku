import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/book_service.dart';
import '../models/admin_category_item.dart';

class CategoryFormModal extends StatefulWidget {
  final AdminCategoryItem? initialCategory;
  final ValueChanged<AdminCategoryItem> onSaved;

  const CategoryFormModal({
    super.key,
    this.initialCategory,
    required this.onSaved,
  });

  static Future<void> show({
    required BuildContext context,
    AdminCategoryItem? initialCategory,
    required ValueChanged<AdminCategoryItem> onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryFormModal(
        initialCategory: initialCategory,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<CategoryFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _rackController;
  int _selectedFloor = 1;
  IconData _selectedIcon = Icons.auto_stories_rounded;
  bool _isSaving = false;

  final List<IconData> _availableIcons = [
    Icons.auto_stories_rounded,
    Icons.menu_book_rounded,
    Icons.school_rounded,
    Icons.computer_rounded,
    Icons.trending_up_rounded,
    Icons.psychology_rounded,
    Icons.import_contacts_rounded,
    Icons.toys_rounded,
    Icons.science_rounded,
    Icons.palette_rounded,
    Icons.history_edu_rounded,
    Icons.public_rounded,
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    _nameController = TextEditingController(text: cat?.name ?? '');
    _codeController = TextEditingController(text: cat?.code ?? '');
    _rackController = TextEditingController(text: cat?.rackLocation ?? '');
    _selectedFloor = cat?.floor ?? 1;
    _selectedIcon = cat?.icon ?? Icons.auto_stories_rounded;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _rackController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.initialCategory != null;
    final id = isEdit ? widget.initialCategory!.id : '';
    final bookCount = isEdit ? widget.initialCategory!.bookCount : 0;

    final item = AdminCategoryItem(
      id: id,
      name: _nameController.text.trim(),
      code: _codeController.text.trim().toUpperCase(),
      rackLocation: _rackController.text.trim(),
      floor: _selectedFloor,
      bookCount: bookCount,
      icon: _selectedIcon,
    );

    setState(() => _isSaving = true);
    try {
      final savedCat = isEdit
          ? await BookService.updateCategory(item)
          : await BookService.createCategory(item);

      if (!mounted) return;
      widget.onSaved(savedCat);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan kategori: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialCategory != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    isEdit ? 'Ubah Kategori Buku' : 'Tambah Kategori Baru',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola nama klasifikasi dan pemetaan rak fisik gerai',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Nama Kategori Field
                  _buildLabel('Nama Kategori'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Nama kategori wajib diisi' : null,
                    decoration: _inputDecoration(
                      hint: 'cth. Novel & Sastra Fiksi',
                      prefixIcon: Icons.label_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kode Kategori Field & Lantai Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Kode Kategori'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Kode wajib diisi'
                                  : null,
                              decoration: _inputDecoration(
                                hint: 'cth. NVL-01',
                                prefixIcon: Icons.qr_code_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Lantai Penempatan'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildFloorChoice(1, 'Lt. 1'),
                                const SizedBox(width: 8),
                                _buildFloorChoice(2, 'Lt. 2'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Lokasi Rak Field
                  _buildLabel('Penempatan Rak Fisik'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _rackController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Lokasi rak toko wajib diisi'
                        : null,
                    decoration: _inputDecoration(
                      hint: 'cth. Rak A1 - Sisi Timur',
                      prefixIcon: Icons.pin_drop_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Icon Picker
                  _buildLabel('Ikon Kategori'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableIcons.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving ? null : _handleSave,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Tambahkan Kategori',
                            style: AppTypography.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Batal',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMd.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildFloorChoice(int floor, String label) {
    final isSelected = _selectedFloor == floor;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFloor = floor;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMd.copyWith(
        color: AppColors.outline,
        fontSize: 13,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
      filled: true,
      fillColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
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
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }
}
