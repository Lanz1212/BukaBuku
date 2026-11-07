import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../../shared/widgets/bookstore_bottom_nav.dart';
import '../../cart/screens/cart_screen.dart';
import '../../category/screens/category_screen.dart';
import '../../favorite/screens/favorite_screen.dart';
import '../../home/home_screen.dart';
import '../../notification/screens/notification_screen.dart';
import '../../order/screens/order_list_screen.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_quote_banner.dart';
import '../widgets/profile_stats_row.dart';
import 'edit_profile_screen.dart';
import 'shipping_address_screen.dart';
import 'help_center_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import '../../auth/login_screen.dart';
import '../../auth/services/auth_service.dart';

/// Main Profile Screen for Toko Buku Budi
/// Follows DESIGN.md, AppColors, AppTypography, and real database values.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile _user = UserProfile.defaultProfile;
  int _addressCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileService.fetchCurrentUserProfile();
      final addresses = await ProfileService.fetchUserAddresses();
      if (mounted) {
        setState(() {
          _user = profile;
          _addressCount = addresses.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updated = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(user: _user)),
    );

    if (updated != null && mounted) {
      setState(() {
        _user = updated;
      });
      _loadProfile();
    }
  }

  Future<void> _navigateToShippingAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShippingAddressScreen()),
    );
    if (mounted) {
      _loadProfile();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keluar dari Akun?',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Buka Buku Anda?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.titleMd.copyWith(
                fontSize: 14,
                color: AppColors.outline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Keluar',
              style: AppTypography.titleMd.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotice(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $featureName segera hadir di Buka Buku!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 4) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CategoryScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrderListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Profil Akun',
        showNotificationButton: true,
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primaryContainer,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    ProfileHeaderCard(
                      user: _user,
                      onEditPressed: _navigateToEditProfile,
                    ),
                    const SizedBox(height: 14),

                    // Stats Row (Pesanan & Buku Favorit)
                    ProfileStatsRow(
                      orderCount: _user.orderCount,
                      favoriteCount: _user.favoriteCount,
                      onOrdersTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderListScreen(),
                          ),
                        );
                      },
                      onFavoritesTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Literary Quote Banner
                    const ProfileQuoteBanner(),
                    const SizedBox(height: 20),

                    // Section 1: Aktivitas Saya
                    ProfileMenuSection(
                      title: 'Aktivitas Saya',
                      items: [
                        ProfileMenuTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pesanan Saya',
                          subtitle: 'Riwayat & status pesanan buku',
                          badgeText: '${_user.orderCount} Pesanan',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OrderListScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.favorite_border_rounded,
                          title: 'Buku Favorit',
                          subtitle: 'Koleksi buku impian yang disimpan',
                          badgeText: '${_user.favoriteCount} Buku',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FavoriteScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Section 2: Pengaturan Akun
                    ProfileMenuSection(
                      title: 'Pengaturan Akun',
                      items: [
                        ProfileMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Nama, email, nomor handphone & foto',
                          onTap: _navigateToEditProfile,
                        ),
                        ProfileMenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat Pengiriman',
                          subtitle: 'Kelola alamat rumah dan kantor tujuan',
                          badgeText: '$_addressCount Alamat',
                          onTap: _navigateToShippingAddress,
                        ),
                        ProfileMenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifikasi',
                          subtitle: 'Atur pemberitahuan pesanan & promo',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Keamanan Akun',
                          subtitle: 'Kata sandi & verifikasi login',
                          onTap: () => _showFeatureNotice('Keamanan Akun'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Section 3: Tentang & Bantuan
                    ProfileMenuSection(
                      title: 'Tentang & Bantuan',
                      items: [
                        ProfileMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Pusat Bantuan',
                          subtitle: 'FAQ, panduan belanja & customer care',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: 'Tentang Buka Buku',
                          subtitle: 'Gerai Utama Buka Buku Cikini',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.description_outlined,
                          title: 'Syarat & Kebijakan Privasi',
                          subtitle: 'Aturan layanan & keamanan transaksi',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 19,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Keluar dari Akun',
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Version & Footer
                    Column(
                      children: [
                        Text(
                          'Buka Buku v1.0.0',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Menemani Pembaca Indonesia Sejak 1982',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            BookstoreBottomNav(
              currentIndex: 4,
              onTabSelected: _handleBottomNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
