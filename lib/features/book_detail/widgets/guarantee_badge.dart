import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

/// Guarantee pill: 100% Original & Bergaransi Toko Buku Budi
class GuaranteeBadge extends StatelessWidget {
  const GuaranteeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F6ED),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: const Color(0xFF3F8F5F).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: Color(0xFF287948),
            ),
            const SizedBox(width: 6),
            Text(
              '100% Original & Bergaransi Toko Buku Budi',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF1F6B3E),
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
