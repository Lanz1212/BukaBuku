import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/payment_success_bento_card.dart';
import '../widgets/payment_success_hero.dart';
import '../widgets/payment_success_wa_banner.dart';

/// Halaman Pembayaran Berhasil (Status Transaksi)
/// Follows DESIGN.md, AppColors, AppTypography, and Stitch screen e2f28554245c400da3bb9e5e1aea0ad0.
class PaymentSuccessScreen extends StatelessWidget {
  final String orderId;
  final int totalAmount;
  final String paymentTime;
  final String paymentMethod;
  final List<PaymentSuccessItem> books;
  final String deliveryTitle;
  final String deliveryAddress;
  final String customerPhone;
  final VoidCallback? onViewOrderPressed;
  final VoidCallback? onBackToHomePressed;

  const PaymentSuccessScreen({
    super.key,
    this.orderId = '#ORD00125',
    this.totalAmount = 181000,
    this.paymentTime = '12 Mei 2024, 14:32 WIB',
    this.paymentMethod = 'QRIS (GoPay/BCA)',
    this.books = const [
      PaymentSuccessItem(
        title: 'Atomic Habits',
        subtitle: 'James Clear • 1x Hardcover',
        price: 'Rp108.000',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDuro3027OrnxnzHhMWNNhxlL6yQ7uRMP4gN56vlkj8gMZdzZ7-U7J-AiMpN9z6agF63Q5IceDcr-ELrDh46dR-dg4sNIRfuvNTfmG0GDGb1H-GjJyb3nBFfSVJREh0B_fT9xfanJsispJlPm4rdAP3oZObX-VkWht5KFxVjOdeqFAeGSlto5ORp0V83N93AtcA-drkc4EIiM7dyJbCUw7h8pSJesulR-EIhER1dmhq5uEeNEB6zrFljQ',
      ),
      PaymentSuccessItem(
        title: 'Filosofi Teras',
        subtitle: 'Henry Manampiring • 1x Softcover',
        price: 'Rp73.000',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAgMcYIiXw_LcINzOt10Cy-DAbM_FwupVBFcX6ri784BXOkvN1IGR4WjYyuCIDZx6eMRPwmygUvprleq8iia-an8eMjCD6WrDBL9QT5YuUUU9OgzF9p67zeZod1FsUWNcrhXGTK1doxZMRyYpvf1fOgRUrY6D87HxD__vJq4kqCq9lAVY0tM-o9hb6QfgiguyYqQlNN0mvC6U8FQXV6Oy2AAo4-SsE7AQI8b8NMSsZjMpKn9ySqndC-QA',
      ),
    ],
    this.deliveryTitle = 'Kurir Antar ke Rumah',
    this.deliveryAddress = 'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat',
    this.customerPhone = '0812-3456-7890',
    this.onViewOrderPressed,
    this.onBackToHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Minimalist Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Status Transaksi',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (onBackToHomePressed != null) {
                        onBackToHomePressed!();
                      } else {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Hero Section
                    const PaymentSuccessHero(),

                    const SizedBox(height: 12),

                    // Main Bento Transaction Summary Card
                    PaymentSuccessBentoCard(
                      totalAmount: totalAmount,
                      orderId: orderId,
                      paymentTime: paymentTime,
                      paymentMethod: paymentMethod,
                      books: books,
                      deliveryTitle: deliveryTitle,
                      deliveryAddress: deliveryAddress,
                    ),

                    const SizedBox(height: 12),

                    // WhatsApp Delivery Notice Banner
                    PaymentSuccessWaBanner(
                      phoneNumber: customerPhone,
                    ),

                    const SizedBox(height: 20),

                    // Bottom Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (onViewOrderPressed != null) {
                            onViewOrderPressed!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Membuka Detail Pesanan $orderId...'),
                                backgroundColor: AppColors.primaryContainer,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lihat Pesanan',
                              style: AppTypography.labelLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (onBackToHomePressed != null) {
                            onBackToHomePressed!();
                          } else {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Beranda',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
