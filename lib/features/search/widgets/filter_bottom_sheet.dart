import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Filter criteria model passed back on apply
class FilterResult {
  final String sortOption;
  final Set<String> categories;
  final RangeValues priceRange;
  final String stockOption; // 'all' | 'instock' | 'cikini'

  const FilterResult({
    required this.sortOption,
    required this.categories,
    required this.priceRange,
    required this.stockOption,
  });
}

/// Interactive Bottom Sheet matching the Stitch Filter Modal design
class FilterBottomSheet extends StatefulWidget {
  final String currentSort;
  final Set<String> initialCategories;
  final RangeValues initialPriceRange;
  final String initialStockOption;
  final ValueChanged<FilterResult> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentSort,
    required this.initialCategories,
    required this.initialPriceRange,
    required this.initialStockOption,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedSort;
  late Set<String> _selectedCategories;
  late RangeValues _priceRange;
  late String _selectedStockOption;

  String _formatCurrency(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  final List<String> _sortOptions = [
    'Terbaru',
    'Harga termurah',
    'Harga tertinggi',
    'Terpopuler',
  ];

  final List<String> _categoryOptions = [
    'Novel',
    'Psikologi',
    'Pengembangan Diri',
    'Bisnis',
    'Teknologi',
    'Komik',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSort;
    _selectedCategories = Set<String>.from(
      widget.initialCategories.isNotEmpty
          ? widget.initialCategories
          : {'Psikologi', 'Pengembangan Diri'},
    );
    _priceRange = widget.initialPriceRange;
    _selectedStockOption = widget.initialStockOption;
  }

  void _resetFilter() {
    setState(() {
      _selectedSort = 'Terpopuler';
      _selectedCategories = {'Psikologi', 'Pengembangan Diri'};
      _priceRange = const RangeValues(50000, 150000);
      _selectedStockOption = 'instock';
    });
  }

  int _calculateMatchedBooks() {
    // Dynamically calculate matching books preview count
    int count = 12;
    if (_selectedCategories.isEmpty) count = 28;
    if (_selectedStockOption == 'cikini') count = 6;
    if (_priceRange.end < 100000) count = (count * 0.5).round();
    return count.clamp(1, 45);
  }

  @override
  Widget build(BuildContext context) {
    final int matchedCount = _calculateMatchedBooks();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E5B4636),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                children: [
                  // Handle Bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 22,
                            color: AppColors.primaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter & Urutkan',
                            style: AppTypography.headlineSm.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(9999),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceContainer, height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Urutkan Berdasarkan
                    _buildSectionHeader(
                      title: 'Urutkan Berdasarkan',
                      trailingText: '1 dipilih',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sortOptions.map((sort) {
                        final bool isSelected = sort == _selectedSort;
                        return _buildFilterPill(
                          label: sort,
                          isSelected: isSelected,
                          showCheck: false,
                          onTap: () {
                            setState(() {
                              _selectedSort = sort;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),

                    // Section 2: Kategori Pembaca
                    _buildSectionHeader(
                      title: 'Kategori Pembaca',
                      trailingText: '${_selectedCategories.length} dipilih',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categoryOptions.map((cat) {
                        final bool isSelected = _selectedCategories.contains(cat);
                        return _buildFilterPill(
                          label: cat,
                          isSelected: isSelected,
                          showCheck: true,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCategories.remove(cat);
                              } else {
                                _selectedCategories.add(cat);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),

                    // Section 3: Rentang Harga (Rp)
                    _buildSectionHeader(
                      title: 'Rentang Harga (Rp)',
                      trailingText: 'Maks Rp 500.000',
                      trailingColor: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    // Dual Price Input Display
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceBox(
                            label: 'Harga Minimum',
                            amount: _formatCurrency(_priceRange.start.round()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPriceBox(
                            label: 'Harga Maksimum',
                            amount: _formatCurrency(_priceRange.end.round()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dual Range Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryContainer,
                        inactiveTrackColor: AppColors.surfaceContainerHigh,
                        trackHeight: 6,
                        thumbColor: AppColors.surfaceContainerLowest,
                        rangeThumbShape: const _CustomRoundThumbShape(
                          enabledThumbRadius: 10,
                          innerDotRadius: 4,
                          innerDotColor: AppColors.primaryContainer,
                        ),
                        overlayColor: AppColors.primaryContainer.withValues(alpha: 0.12),
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 500000,
                        divisions: 50,
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                    ),
                    // Scale Labels below slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp 0',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Rp 250.000',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Rp 500.000+',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Section 4: Ketersediaan & Pengambilan
                    Text(
                      'Ketersediaan & Pengambilan',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Radio Cards
                    _buildStockRadioCard(
                      value: 'all',
                      title: 'Semua Buku',
                      subtitle: 'Termasuk pemesanan pre-order & restock',
                    ),
                    const SizedBox(height: 8),
                    _buildStockRadioCard(
                      value: 'instock',
                      title: 'Hanya Stok Tersedia di Toko',
                      subtitle: 'Siap dikirim atau dibaca sekarang',
                      badgeIcon: Icons.check_circle_rounded,
                      badgeColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 8),
                    _buildStockRadioCard(
                      value: 'cikini',
                      title: 'Bisa Ambil Hari Ini di Cikini',
                      subtitle: 'Ambil langsung di meja kasir Budi Cikini',
                      badgeIcon: Icons.storefront_rounded,
                      badgeColor: AppColors.onSurfaceVariant,
                    ),

                    const SizedBox(height: 16),

                    // Section 5: Catatan Penjaga Toko
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.local_library_outlined,
                            size: 22,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catatan Penjaga Toko',
                                  style: AppTypography.labelMd.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Menampilkan buku yang sudah dikurasi berdasarkan edisi cetak terbaru & kertas bookpaper ramah mata.',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Actions
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Reset Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _resetFilter,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.restart_alt_rounded,
                              size: 18,
                              color: AppColors.primaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Reset',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Apply Primary Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApply(
                            FilterResult(
                              sortOption: _selectedSort,
                              categories: _selectedCategories,
                              priceRange: _priceRange,
                              stockOption: _selectedStockOption,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Terapkan Filter',
                              style: AppTypography.labelLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '($matchedCount Buku)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSectionHeader({
    required String title,
    required String trailingText,
    Color? trailingColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          trailingText,
          style: AppTypography.caption.copyWith(
            color: trailingColor ?? AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required bool showCheck,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected && showCheck ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.16),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected && showCheck) ...[
                const Icon(
                  Icons.check,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBox({required String label, required String amount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Rp',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  amount,
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockRadioCard({
    required String value,
    required String title,
    required String subtitle,
    IconData? badgeIcon,
    Color? badgeColor,
  }) {
    final bool isSelected = _selectedStockOption == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStockOption = value;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.outlineVariant
                  : AppColors.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Radio Circle
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badgeIcon != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            badgeIcon,
                            size: 16,
                            color: badgeColor ?? AppColors.secondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Thumb Shape with an inner dot matching the design
class _CustomRoundThumbShape extends RangeSliderThumbShape {
  final double enabledThumbRadius;
  final double innerDotRadius;
  final Color innerDotColor;

  const _CustomRoundThumbShape({
    this.enabledThumbRadius = 10.0,
    this.innerDotRadius = 4.0,
    required this.innerDotColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    // Outer White Circle
    final Paint outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Subtle Shadow
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center + const Offset(0, 1.5), radius: enabledThumbRadius));
    canvas.drawShadow(shadowPath, const Color(0x335B4636), 3, true);

    canvas.drawCircle(center, enabledThumbRadius, outerPaint);

    // Inner Dot
    final Paint innerPaint = Paint()
      ..color = innerDotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerDotRadius, innerPaint);
  }
}
