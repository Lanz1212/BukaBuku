import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_simulation_flow.dart';

/// Segmented tab selector for switching order confirmation simulation flows
/// (Antar Rumah, Ambil Online, Bayar Kasir).
class OrderSimulationTabs extends StatelessWidget {
  final OrderSimulationFlow selectedFlow;
  final ValueChanged<OrderSimulationFlow> onFlowChanged;

  const OrderSimulationTabs({
    super.key,
    required this.selectedFlow,
    required this.onFlowChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Simulasi Alur:',
          style: AppTypography.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: OrderSimulationFlow.values.map((flow) {
              final isSelected = flow == selectedFlow;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onFlowChanged(flow),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      flow.tabLabel,
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
