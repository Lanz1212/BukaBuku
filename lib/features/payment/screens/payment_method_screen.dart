import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/payment_method_item.dart';
import '../widgets/payment_app_bar.dart';
import '../widgets/payment_method_option_tile.dart';
import '../widgets/payment_order_summary_banner.dart';
import '../widgets/payment_trust_badges.dart';
import 'qris_payment_screen.dart';

/// Screen 1: Halaman Pilihan Metode Pembayaran
/// Conforms to DESIGN.md, AppColors, AppTypography, and Stitch screen ef4529a7f95748e6a703553a2f0be1a2.
class PaymentMethodScreen extends StatefulWidget {
  final String orderId;
  final int totalAmount;
  final int bookCount;
  final String initialSelectedId;

  const PaymentMethodScreen({
    super.key,
    this.orderId = '#ORD00125',
    this.totalAmount = 181000,
    this.bookCount = 2,
    this.initialSelectedId = 'qris',
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String _selectedMethodId;
  final List<PaymentMethodItem> _allMethods = PaymentMethodItem.defaultMethods;

  @override
  void initState() {
    super.initState();
    _selectedMethodId = widget.initialSelectedId;
  }

  PaymentMethodItem get _selectedMethod {
    return _allMethods.firstWhere(
      (m) => m.id == _selectedMethodId,
      orElse: () => _allMethods.first,
    );
  }

  void _onContinuePayment() {
    if (_selectedMethodId == 'qris') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QrisPaymentScreen(
            orderId: widget.orderId,
            totalAmount: widget.totalAmount,
          ),
        ),
      );
    } else {
      // If choosing VA, E-Wallet, or Cash, notify reader or return selection
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Metode pembayaran ${_selectedMethod.title} telah dipilih.',
          ),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop(_selectedMethod);
            },
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final instantMethods = _allMethods
        .where((m) => m.category == PaymentCategory.instantDigital)
        .toList();
    final onSiteMethods = _allMethods
        .where((m) => m.category == PaymentCategory.onSite)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PaymentAppBar(
        title: 'Metode Pembayaran',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // 1. Order Amount Summary Card & Delivery Context
                  PaymentOrderSummaryBanner(
                    orderId: widget.orderId,
                    totalAmount: widget.totalAmount,
                    bookCount: widget.bookCount,
                  ),

                  const SizedBox(height: 24),

                  // 2. Category 1: Pembayaran Instan & Digital
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pembayaran Instan & Digital',
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Bebas Biaya Admin',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Instant digital options list
                  ...instantMethods.map((method) {
                    return PaymentMethodOptionTile(
                      item: method,
                      isSelected: method.id == _selectedMethodId,
                      onTap: () {
                        setState(() {
                          _selectedMethodId = method.id;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // 3. Category 2: Pembayaran di Tempat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pembayaran di Tempat',
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Khusus Pengambilan',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // On-site options list
                  ...onSiteMethods.map((method) {
                    return PaymentMethodOptionTile(
                      item: method,
                      isSelected: method.id == _selectedMethodId,
                      onTap: () {
                        setState(() {
                          _selectedMethodId = method.id;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // 4. Trust and Reassurance Card
                  const PaymentSecurityGuaranteeCard(),

                  const SizedBox(height: 10),

                  // 5. Atmosphere Bookstore Note
                  const PaymentBookstoreNoteBanner(),

                  const SizedBox(height: 110), // Bottom bar offset
                ],
              ),
            ),

            // Sticky Bottom CTA Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.outlineVariant.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selected Tracker Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Metode dipilih:',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _selectedMethod.title,
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _onContinuePayment,
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
                                'Lanjutkan Pembayaran',
                                style: AppTypography.labelLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
