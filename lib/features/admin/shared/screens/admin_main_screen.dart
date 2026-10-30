import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../book_management/screens/book_management_screen.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';
import '../../order_management/screens/order_management_screen.dart';
import '../../stock_management/screens/stock_management_screen.dart';
import '../../profile/screens/admin_profile_screen.dart';
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
            AdminProfileScreen(
              onExitAdmin: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
