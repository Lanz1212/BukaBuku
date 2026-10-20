import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../book_management/screens/book_management_screen.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';
import '../widgets/admin_app_bar.dart';
import '../widgets/admin_bottom_nav.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdminMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Kelola Buku';
      case 2:
        return 'Pesanan Masuk';
      case 3:
        return 'Pemindai QR';
      case 4:
        return 'Profil Pengelola';
      default:
        return 'Admin Panel';
    }
  }

  void _onTabSelected(int index) {
    if (index == 3) {
      // Center Scan QR shortcut
      _showScanNotice();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showScanNotice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.onPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pemindai QR Kasir',
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Arahkan kamera ke QR code pesanan pembeli untuk validasi dan serah terima buku.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Simulasi: QR Pesanan #ORD00125 berhasil divalidasi!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Simulasi Scan Valid'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(
        title: _getTitle(),
        onExitAdmin: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Dashboard
            AdminDashboardScreen(
              onNavigateToBooks: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),

            // Tab 1: Kelola Buku
            const BookManagementScreen(),

            // Tab 2: Pesanan Masuk (Placeholder / Coming Soon)
            _buildPlaceholderTab(
              icon: Icons.receipt_long_rounded,
              title: 'Pesanan Masuk Toko',
              subtitle: '12 pesanan siap diambil dan 5 pesanan baru menunggu proses.',
            ),

            // Tab 3: Scan QR (Index 3 handled via modal, keep placeholder for stack)
            _buildPlaceholderTab(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Pemindai QR',
              subtitle: 'Scan QR nota pesanan pelanggan',
            ),

            // Tab 4: Profil Pengelola
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.onPrimary,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Budi Santoso',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Owner & Admin Utama Toko',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.storefront_rounded),
              label: const Text('Kembali ke Mode Pembeli'),
            ),
          ],
        ),
      ),
    );
  }
}
