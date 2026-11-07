import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Admin Profile Header Card displaying admin identity, store assignment, and access privileges
class AdminProfileHeader extends StatelessWidget {
  final String name;
  final String role;
  final String storeLocation;
  final String adminId;
  final String email;
  final String phone;
  final String joinedDate;
  final String accessLevel;
  final VoidCallback? onEditProfile;

  const AdminProfileHeader({
    super.key,
    this.name = 'Budi Pratama',
    this.role = 'Owner / Super Admin',
    this.storeLocation = 'Gerai Buka Buku',
    this.adminId = 'BUDI-ADM-01',
    this.email = 'admin@bukabuku.id',
    this.phone = '+62 812-3456-7890',
    this.joinedDate = 'Mei 2021',
    this.accessLevel = 'Penuh (Full)',
    this.onEditProfile,
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
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Identity Section (Avatar + Name + Role + Contacts)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verified badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/Profile.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name, Role Badge, Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            size: 12,
                            color: AppColors.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            role,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Gerai & ID
                    Text(
                      'Gerai Utama Cikini • ID: $adminId',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Contact info
                    Text(
                      '$email • $phone',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-Column Info Row
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  label: 'Toko Aktif',
                  value: storeLocation,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoBox(
                  label: 'Bergabung',
                  value: joinedDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoBox(
                  label: 'Akses Sesi',
                  value: accessLevel,
                  valueColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.onSurface,
              fontSize: 12.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
