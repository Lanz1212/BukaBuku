import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QrActionButtons extends StatelessWidget {
  final bool isTorchOn;
  final VoidCallback onToggleTorch;
  final VoidCallback onManualInput;

  const QrActionButtons({
    super.key,
    required this.isTorchOn,
    required this.onToggleTorch,
    required this.onManualInput,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left: Flashlight Button
          Expanded(
            child: _buildActionButton(
              icon: isTorchOn
                  ? Icons.flashlight_on_rounded
                  : Icons.flashlight_on_outlined,
              label: isTorchOn ? 'Matikan Senter' : 'Nyalakan Senter',
              iconColor: isTorchOn
                  ? const Color(0xFFD99A35)
                  : AppColors.onSurface,
              onTap: onToggleTorch,
            ),
          ),
          const SizedBox(width: 12),

          // Right: Manual Input Button
          Expanded(
            child: _buildActionButton(
              icon: Icons.keyboard_alt_outlined,
              label: 'Input Manual #ORD',
              iconColor: AppColors.onSurface,
              onTap: onManualInput,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B4636).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
