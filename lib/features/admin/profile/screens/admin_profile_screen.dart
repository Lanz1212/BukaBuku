import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/cashier_log_service.dart';
import '../../notifications/screens/admin_notification_screen.dart';
import '../../../profile/models/user_profile.dart';
import '../../../profile/services/profile_service.dart';
import '../../../profile/screens/edit_profile_screen.dart';
import '../widgets/admin_profile_header.dart';
import '../widgets/admin_info_tile.dart';
import '../widgets/admin_section_header.dart';
import 'staff_guide_screen.dart';
import 'cashier_log_screen.dart';
import '../../store_settings/screens/store_settings_screen.dart';
import '../../../auth/login_screen.dart';
import '../../../auth/services/auth_service.dart';

/// Admin Profile & System Settings Screen (Tab 4 in Admin Panel)
/// Matches design from Stitch Toko Buku Budi Mobile UI & DESIGN.md
class AdminProfileScreen extends StatefulWidget {
  final VoidCallback? onExitAdmin;

  const AdminProfileScreen({
    super.key,
    this.onExitAdmin,
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.fetchCurrentUserProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

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
          'Apakah Anda yakin ingin mengakhiri sesi admin Buka Buku dan kembali ke halaman login?',
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
              final adminName = _profile?.name ?? await CashierLogService.getCurrentAdminName();
              await CashierLogService.recordLog(
                action: 'Tutup Sesi Admin',
                details: 'Admin $adminName keluar dari sesi aplikasi',
                tag: 'Shift',
              );
              CashierLogService.clearCachedAdminName();
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
    final profile = _profile;
    final name = profile?.name ?? 'Admin Toko';
    final email = profile?.email.isNotEmpty == true ? profile!.email : 'admin@bukabuku.id';
    final phone = profile?.phone.isNotEmpty == true ? profile!.phone : '+62 812-3456-7890';
    final adminId = profile != null && profile.id.isNotEmpty
        ? 'ADM-${profile.id.substring(0, math.min(6, profile.id.length)).toUpperCase()}'
        : 'BUDI-ADM-01';

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading) ...[
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 10),
            ],
            // 1. Admin Identity Card
            AdminProfileHeader(
              name: name,
              email: email,
              phone: phone,
              adminId: adminId,
              role: 'Staff Admin / Kasir Toko',
              onEditProfile: () async {
                if (profile != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: profile),
                    ),
                  );
                  CashierLogService.clearCachedAdminName();
                  _loadProfile();
                } else {
                  _showNotice(context, 'Memuat data profil...');
                }
              },
            ),
            const SizedBox(height: 18),

            // 2. Section: Pengaturan & Bisnis
            const AdminSectionHeader(title: 'Pengaturan & Bisnis'),
            _buildCardGroup(
              children: [
                AdminInfoTile(
                  icon: Icons.storefront_outlined,
                  title: 'Pengaturan Toko',
                  titleBadge: 'Buka Buku',
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
                ValueListenableBuilder<int>(
                  valueListenable: AdminNotificationService.unreadCountNotifier,
                  builder: (context, unreadCount, _) {
                    return AdminInfoTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi Admin',
                      subtitle: 'Pesanan baru, stok menipis, verifikasi QR pickup',
                      trailingBadge: unreadCount > 0 ? '$unreadCount Baru' : null,
                      trailingBadgeColor: AppColors.secondary,
                      showDivider: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminNotificationScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 3. Section: Sistem & Keamanan
            const AdminSectionHeader(title: 'Sistem & Keamanan'),
            _buildCardGroup(
              children: [
                AdminInfoTile(
                  icon: Icons.history_rounded,
                  title: 'Log Aktivitas Kasir',
                  subtitle: 'Riwayat login, perubahan stok, & pembukaan laci kas',
                  showDivider: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CashierLogScreen(),
                      ),
                    );
                  },
                ),
                AdminInfoTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Panduan Staf & Bantuan',
                  subtitle: 'SOP inventaris, panduan kurasi buku, & CS teknis',
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StaffGuideScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 4. Section: Sesi Akun
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

            // 5. System Status Footer
            _buildSystemFooter(),
            const SizedBox(height: 20),
          ],
        ),
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
          'Buka Buku Admin v2.4.1 (Build 108)',
          style: AppTypography.caption.copyWith(
            color: AppColors.outlineVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
