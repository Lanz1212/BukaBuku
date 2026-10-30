import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

enum ScanScenario {
  validOnline,
  validCash,
  invalidQr,
}

class ScanScenarioTabs extends StatelessWidget {
  final ScanScenario selectedScenario;
  final ValueChanged<ScanScenario> onScenarioChanged;

  const ScanScenarioTabs({
    super.key,
    required this.selectedScenario,
    required this.onScenarioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTab(
            scenario: ScanScenario.validOnline,
            label: 'Valid (Online)',
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(width: 8),
          _buildTab(
            scenario: ScanScenario.validCash,
            label: 'Valid (Cash)',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(width: 8),
          _buildTab(
            scenario: ScanScenario.invalidQr,
            label: 'Invalid QR',
            icon: Icons.error_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required ScanScenario scenario,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = selectedScenario == scenario;
    return InkWell(
      onTap: () => onScenarioChanged(scenario),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
