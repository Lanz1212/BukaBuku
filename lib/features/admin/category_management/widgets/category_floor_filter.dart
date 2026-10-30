import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CategoryFloorFilter extends StatelessWidget {
  final int selectedFloor; // 0: All, 1: Floor 1, 2: Floor 2
  final int countAll;
  final int countFloor1;
  final int countFloor2;
  final ValueChanged<int> onFloorSelected;

  const CategoryFloorFilter({
    super.key,
    required this.selectedFloor,
    required this.countAll,
    required this.countFloor1,
    required this.countFloor2,
    required this.onFloorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            floor: 0,
            label: 'Semua ($countAll)',
          ),
          const SizedBox(width: 8),
          _buildChip(
            floor: 1,
            label: 'Lantai 1 • Rak A-C ($countFloor1)',
          ),
          const SizedBox(width: 8),
          _buildChip(
            floor: 2,
            label: 'Lantai 2 • Rak D-F ($countFloor2)',
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required int floor,
    required String label,
  }) {
    final isSelected = selectedFloor == floor;

    return InkWell(
      onTap: () => onFloorSelected(floor),
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
