import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Communication Channels & Customer Service Contact Card
class StoreContactCard extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController whatsappController;

  const StoreContactCard({
    super.key,
    required this.phoneController,
    required this.whatsappController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Icon(
                Icons.perm_phone_msg_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Kanal Komunikasi & Layanan Pelanggan',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label: Nomor Telepon Gerai
          Text(
            'Nomor Telepon Gerai',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),

          // Phone Field with +62 prefix
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(11),
                      bottomLeft: Radius.circular(11),
                    ),
                  ),
                  child: Text(
                    '+62',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      hintText: '021-xxxx-xxxx',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Label: Nomor WhatsApp Resmi + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nomor WhatsApp Resmi',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Pickup & CS Toko',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // WhatsApp Field with leading chat icon
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 16,
                      color: Color(0xFF25D366),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: whatsappController,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      hintText: '0812-xxxx-xxxx',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Digunakan otomatis untuk notifikasi status pesanan ambil di tempat.',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
