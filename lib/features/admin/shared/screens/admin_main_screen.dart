import 'package:flutter/material.dart';
import '../../../../core/services/admin_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../book_management/screens/book_management_screen.dart';
import '../../dashboard/screens/admin_dashboard_screen.dart';
import '../../notifications/screens/admin_notification_screen.dart';
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
  String? _targetStockBookId;
  int _stockScreenRebuildKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    AdminNotificationService.countUnread();
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

  void _navigateToStockWithBook(String bookId) {
    setState(() {
      _currentIndex = 2;
      _targetStockBookId = bookId;
      _stockScreenRebuildKeyCounter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AdminAppBar(
        title: _getTitle(),
        onNotificationsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminNotificationScreen(),
            ),
          ).then((_) {
            AdminNotificationService.countUnread();
          });
        },
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Dashboard
            AdminDashboardScreen(
              onNavigateToBooks: () => setState(() => _currentIndex = 1),
              onNavigateToStock: () {
                setState(() {
                  _currentIndex = 2;
                  _targetStockBookId = null;
                });
              },
              onNavigateToOrders: () => setState(() => _currentIndex = 3),
              onNavigateToStockWithBook: _navigateToStockWithBook,
            ),

            // Tab 1: Kelola Buku
            const BookManagementScreen(),

            // Tab 2: Stok Buku
            StockManagementScreen(
              key: ValueKey('stock_screen_${_targetStockBookId}_$_stockScreenRebuildKeyCounter'),
              initialTargetBookId: _targetStockBookId,
              autoOpenAdjustModal: _targetStockBookId != null,
            ),

            // Tab 3: Pesanan Masuk
            const OrderManagementScreen(),

            // Tab 4: Profil Pengelola
            const AdminProfileScreen(),
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
