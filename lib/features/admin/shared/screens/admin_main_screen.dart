import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../book_management/screens/book_management_screen.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';
import '../../order_management/screens/order_management_screen.dart';
import '../../stock_management/screens/stock_management_screen.dart';
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
        return 'Stok Buku';
      case 3:
        return 'Pesanan Masuk';
      case 4:
        return 'Profil Pengelola';
      default:
        return 'Admin Panel';
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
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

            // Tab 2: Stok Buku
            const StockManagementScreen(),

            // Tab 3: Pesanan Masuk
            const OrderManagementScreen(),

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
