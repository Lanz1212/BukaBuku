import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/admin_profile_header.dart';
import '../widgets/admin_shift_card.dart';
import '../widgets/admin_info_tile.dart';
import '../widgets/admin_section_header.dart';
import '../../store_settings/screens/store_settings_screen.dart';
import '../../../auth/login_screen.dart';
import '../../../auth/services/auth_service.dart';

/// Admin Profile & System Settings Screen (Tab 4 in Admin Panel)
/// Matches design from Stitch Toko Buku Budi Mobile UI & DESIGN.md
class AdminProfileScreen extends StatelessWidget {
  final VoidCallback? onExitAdmin;

  const AdminProfileScreen({
    super.key,
    this.onExitAdmin,
  });

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar Akun Admin?',
          style: AppTypography.headlineSm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengakhiri sesi admin Toko Buku Budi dan kembali ke mode pembeli?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Keluar Sesi',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onError,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Admin Identity Card
          AdminProfileHeader(
            onEditProfile: () => _showNotice(context, 'Edit profil admin'),
          ),
          const SizedBox(height: 14),

          // 2. Active Store Shift & Fast Cashier Card
          AdminShiftCard(
            onOpenCashier: () => _showNotice(
              context,
              'Membuka terminal Kasir Cepat Toko Buku Budi Cikini',
            ),
          ),
          const SizedBox(height: 18),

          // 3. Section: Pengaturan & Bisnis
          const AdminSectionHeader(title: 'Pengaturan & Bisnis'),
          _buildCardGroup(
            children: [
              AdminInfoTile(
                icon: Icons.badge_outlined,
                title: 'Akun',
                subtitle: 'Informasi personal admin, ganti sandi & PIN kasir',
                showDivider: true,
                onTap: () => _showNotice(context, 'Buka pengaturan akun admin'),
              ),
              AdminInfoTile(
                icon: Icons.storefront_outlined,
                title: 'Pengaturan Toko',
                titleBadge: 'Cikini Raya',
                subtitle: 'Identitas toko, jam buka, kontak WhatsApp resmi',
                showDivider: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoreSettingsScreen(),
                    ),
                  );
                },
              ),
              AdminInfoTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifikasi',
                subtitle: 'Pesanan baru, stok menipis, peringatan kasir',
                trailingBadge: '3 Baru',
                trailingBadgeColor: AppColors.primaryContainer,
                showDivider: false,
                onTap: () => _showNotice(
                  context,
                  '3 notifikasi penting: 2 pesanan baru, 1 buku stok menipis',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 4. Section: Sistem & Keamanan
          const AdminSectionHeader(title: 'Sistem & Keamanan'),
          _buildCardGroup(
            children: [
              AdminInfoTile(
                icon: Icons.history_rounded,
                title: 'Log Aktivitas Kasir',
                subtitle: 'Riwayat login, perubahan stok, & pembukaan laci kas',
                showDivider: true,
                onTap: () => _showNotice(
                  context,
                  'Buka audit trail & log aktivitas kasir',
                ),
              ),
              AdminInfoTile(
                icon: Icons.menu_book_outlined,
                title: 'Panduan Staf & Bantuan',
                subtitle: 'SOP inventaris, panduan kurasi buku, & CS teknis',
                showDivider: false,
                onTap: () => _showNotice(
                  context,
                  'Buka modul panduan staf Toko Buku Budi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 5. Section: Sesi Akun
          const AdminSectionHeader(title: 'Sesi Akun'),
          _buildCardGroup(
            children: [
              AdminInfoTile(
                icon: Icons.logout_rounded,
                title: 'Keluar Akun',
                subtitle: 'Akhiri sesi admin di perangkat ini dengan aman',
                isDestructive: true,
                showDivider: false,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 6. System Status Footer
          _buildSystemFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSystemFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Sistem Terhubung • Cloud Sync Aktif',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Toko Buku Budi Admin v2.4.1 (Build 108)',
          style: AppTypography.caption.copyWith(
            color: AppColors.outlineVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
