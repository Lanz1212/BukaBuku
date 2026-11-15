import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AdminBookFilterModal extends StatefulWidget {
  final RangeValues minMaxPrice;
  final RangeValues currentPriceRange;
  final String currentStockFilter;
  final String? currentRackFilter;
  final List<String> availableRacks;
  final void Function(
    RangeValues priceRange,
    String stockFilter,
    String? rackFilter,
  ) onApply;
  final VoidCallback onReset;

  const AdminBookFilterModal({
    super.key,
    required this.minMaxPrice,
    required this.currentPriceRange,
    required this.currentStockFilter,
    required this.currentRackFilter,
    required this.availableRacks,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<AdminBookFilterModal> createState() => _AdminBookFilterModalState();
}

class _AdminBookFilterModalState extends State<AdminBookFilterModal> {
  late RangeValues _priceRange;
  late String _stockFilter;
  late String? _rackFilter;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.currentPriceRange.start.clamp(
        widget.minMaxPrice.start,
        widget.minMaxPrice.end,
      ),
      widget.currentPriceRange.end.clamp(
        widget.minMaxPrice.start,
        widget.minMaxPrice.end,
      ),
    );
    _stockFilter = widget.currentStockFilter;
    _rackFilter = widget.currentRackFilter;
  }

  String _formatCurrency(num value) {
    final intVal = value.round();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  void _handleReset() {
    setState(() {
      _priceRange = widget.minMaxPrice;
      _stockFilter = 'Semua';
      _rackFilter = 'Semua';
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final racks = ['Semua', ...widget.availableRacks];
    final selectedRackVal =
        (_rackFilter == null || !racks.contains(_rackFilter))
            ? 'Semua'
            : _rackFilter!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Icons.tune_rounded,
                        color: AppColors.primaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Filter Buku Admin',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _handleReset,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Rentang Harga
            Text(
              'Rentang Harga',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(_priceRange.start),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _formatCurrency(_priceRange.end),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: widget.minMaxPrice.start,
              max: widget.minMaxPrice.end <= widget.minMaxPrice.start
                  ? widget.minMaxPrice.start + 1000
                  : widget.minMaxPrice.end,
              divisions: 40,
              activeColor: AppColors.primaryContainer,
              inactiveColor: AppColors.outlineVariant.withValues(alpha: 0.4),
              labels: RangeLabels(
                _formatCurrency(_priceRange.start),
                _formatCurrency(_priceRange.end),
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 16),

            // 2. Status Stok
            Text(
              'Ketersediaan Stok',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStockChip('Semua'),
                _buildStockChip('Tersedia'),
                _buildStockChip('Menipis'),
                _buildStockChip('Habis'),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Lokasi Rak
            Text(
              'Lokasi Rak Buku',
              style: AppTypography.labelLg.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRackVal,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                  items: racks.map((rack) {
                    return DropdownMenuItem<String>(
                      value: rack,
                      child: Text(
                        rack,
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 13,
                          color: AppColors.onSurface,
                          fontWeight: rack == selectedRackVal
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _rackFilter = (val == 'Semua' ? null : val);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_priceRange, _stockFilter, _rackFilter);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Terapkan Filter',
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockChip(String label) {
    final isSelected = _stockFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _stockFilter = label;
          });
        }
      },
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: AppTypography.caption.copyWith(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected
            ? Colors.transparent
            : AppColors.outlineVariant.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}
