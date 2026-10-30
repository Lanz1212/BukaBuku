import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QrCashierChecklist extends StatefulWidget {
  final int totalItemCount;
  final ValueChanged<bool>? onAllChecked;

  const QrCashierChecklist({
    super.key,
    required this.totalItemCount,
    this.onAllChecked,
  });

  @override
  State<QrCashierChecklist> createState() => _QrCashierChecklistState();
}

class _QrCashierChecklistState extends State<QrCashierChecklist> {
  bool _item1Checked = true;
  bool _item2Checked = true;

  void _notify() {
    widget.onAllChecked?.call(_item1Checked && _item2Checked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 20,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemeriksaan Fisik Kasir',
                      style: AppTypography.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pastikan item sesuai sebelum menyerahkan ke pembeli',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCheckItem(
            value: _item1Checked,
            label: 'Kondisi fisik buku baik (segel / tidak cacat)',
            onChanged: (val) {
              setState(() {
                _item1Checked = val ?? false;
              });
              _notify();
            },
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            value: _item2Checked,
            label:
                'Jumlah buku fisik sesuai dengan pesanan (${widget.totalItemCount} eks)',
            onChanged: (val) {
              setState(() {
                _item2Checked = val ?? false;
              });
              _notify();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? AppColors.success.withValues(alpha: 0.05)
              : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value
                ? AppColors.success.withValues(alpha: 0.25)
                : AppColors.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 12.5,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
