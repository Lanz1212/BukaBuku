import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Store Pickup & Collection Policy Card
class StorePickupPolicyCard extends StatelessWidget {
  final int maxPickupHours;

  const StorePickupPolicyCard({
    super.key,
    this.maxPickupHours = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEEDAC7),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                size: 18,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Kebijakan Pickup & Pengambilan',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Policy Description with bold highlights
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
                fontSize: 13,
                height: 1.45,
              ),
              children: [
                const TextSpan(text: 'Simpan pesanan pickup maksimal '),
                TextSpan(
                  text: '$maxPickupHours jam',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' sejak status '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Siap Diambil',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const TextSpan(
                  text: ' . Lewat tenggat ini, kasir berhak merestok buku ke etalase utama.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Synced Info Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pengaturan batas waktu pickup tersinkronisasi otomatis dengan aplikasi kasir POS.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
