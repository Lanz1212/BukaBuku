import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class PickupActionBar extends StatelessWidget {
  final VoidCallback onScanQr;
  final String? customScanLabel;
  final IconData? customIcon;
  final Color? buttonColor;
  final bool isDisabled;

  const PickupActionBar({
    super.key,
    required this.onScanQr,
    this.customScanLabel,
    this.customIcon,
    this.buttonColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = buttonColor ?? const Color(0xFF382B21);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE8F5E9),
            disabledForegroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isDisabled
                  ? const BorderSide(color: Color(0xFFA5D6A7), width: 1)
                  : BorderSide.none,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          onPressed: isDisabled ? null : onScanQr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                customIcon ?? Icons.qr_code_scanner_rounded,
                size: 20,
                color: isDisabled ? const Color(0xFF2E7D32) : Colors.white,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  customScanLabel ?? 'Scan QR Pickup Customer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLg.copyWith(
                    color: isDisabled ? const Color(0xFF2E7D32) : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
