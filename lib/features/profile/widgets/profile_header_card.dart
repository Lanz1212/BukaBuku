import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/user_profile.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onEditPressed;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondaryFixedDim,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatar(),
            ),
          ),
          const SizedBox(width: 16),

          // Name and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // User Name
                Text(
                  user.name,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Email row
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 14,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  // Phone row
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.phone,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Edit profile icon button
          if (onEditPressed != null)
            IconButton(
              onPressed: onEditPressed,
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.primaryContainer,
              ),
              tooltip: 'Edit Profil',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = user.avatarUrl;
    final hasNetworkUrl = avatarUrl != null &&
        avatarUrl.trim().isNotEmpty &&
        avatarUrl.startsWith('http');

    if (hasNetworkUrl) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final name = user.name.trim();
    if (name.isNotEmpty) {
      final initial = name.characters.first.toUpperCase();
      return Container(
        color: AppColors.primaryContainer,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.primaryContainer,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}
