import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class AdminQuickActions extends StatelessWidget {
  final VoidCallback? onScanQr;
  final VoidCallback? onAddBook;
  final VoidCallback? onManageStock;

  const AdminQuickActions({
    super.key,
    this.onScanQr,
    this.onAddBook,
    this.onManageStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat Admin',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Operasional Toko',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Shortcut 1: QR Scanner (Dark Hero Action)
            Expanded(
              child: _buildHeroAction(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scan QR',
                subtitle: 'Pickup Kasir',
                onTap: onScanQr,
              ),
            ),
            const SizedBox(width: 10),

            // Shortcut 2: Tambah Buku
            Expanded(
              child: _buildStandardAction(
                icon: Icons.library_add_rounded,
                title: 'Tambah Buku',
                subtitle: 'Katalog Baru',
                onTap: onAddBook,
              ),
            ),
            const SizedBox(width: 10),

            // Shortcut 3: Atur Stok
            Expanded(
              child: _buildStandardAction(
                icon: Icons.inventory_2_outlined,
                title: 'Atur Stok',
                subtitle: 'Opname Rak',
                onTap: onManageStock,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroAction({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryFixedDim,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardAction({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  fontSize: 12.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
