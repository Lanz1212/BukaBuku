import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../models/order_model.dart';
import '../widgets/pickup_success_book_item.dart';
import '../widgets/pickup_success_detail_card.dart';
import '../widgets/pickup_success_hero.dart';
import '../widgets/pickup_success_store_photo.dart';

class PickupSuccessScreen extends StatelessWidget {
  final OrderModel? order;

  const PickupSuccessScreen({
    super.key,
    this.order,
  });

  OrderModel get _order => order ?? mockOrders.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Pickup Success',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Celebration Top Graphic & Header
              const PickupSuccessHero(),

              const SizedBox(height: 18),

              // Visual Paper Bag / Handover Snippet Image Banner
              const PickupSuccessStorePhoto(),

              const SizedBox(height: 20),

              // Verification Receipt Bento Card
              PickupSuccessDetailCard(
                orderId: _order.id,
                customerName: _order.customerName,
                cashierName: 'Siti (Kasir 1 - Cikini)',
                pickupTime: '12 Mei 2024, 16:45 WIB',
                totalAmount: _order.totalAmount,
                paymentMethod: 'Lunas via QRIS',
              ),

              const SizedBox(height: 22),

              // Books Handed Over Summary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buku yang Diserahkan',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '2 Fisik + Souvenir',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Free Perk Badge (wooden bookmark + kraft paper wrapper)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Termasuk pembatas buku kayu khas Toko Budi & sampul kraft rapi.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSecondaryFixedVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Handed Over Book Items
              PickupSuccessBookItem(
                category: 'Self Development',
                title: _order.items.isNotEmpty
                    ? _order.items[0].title
                    : 'Atomic Habits',
                author: _order.items.isNotEmpty
                    ? _order.items[0].author
                    : 'James Clear',
                coverUrl: _order.items.isNotEmpty
                    ? _order.items[0].coverUrl
                    : 'https://lh3.googleusercontent.com/aida-public/AB6AXuD_tbxwogOC7QET_Fyd00xL8FVIkybub4HyA4I_BAn32wFFvjXP6yXTe88wImXX-iA_aPUblMNGNhYU3AijkJAg2gB-2cIIHwvkiXfmkavGG4KuWQT2aPYwD8de30XnJD4VmOQmMlJXYYibkOUF--l-Sw_-rxGg1bLGvQDYdesBuDunPeOqt8O1AcvBOTKcC_GhNnweK51Fq-h4BmsFLridoGH2AlV5FM9xBggdG7AacUtmAORmnNfkCg',
              ),

              const SizedBox(height: 10),

              PickupSuccessBookItem(
                category: 'Filsafat Populer',
                title: _order.items.length > 1
                    ? _order.items[1].title
                    : 'Filosofi Teras',
                author: _order.items.length > 1
                    ? _order.items[1].author
                    : 'Henry Manampiring',
                coverUrl: _order.items.length > 1
                    ? _order.items[1].coverUrl
                    : 'https://lh3.googleusercontent.com/aida-public/AB6AXuD3aaIos9DvsKkWZqHq0Kxc1xb6pyQZDISlpxFZ8F_ZJPX2jc1dvkKHotePV0H3tGhZOupX51fREEiIkvAthcqW7qQOjbttsZX2Pf8YQeFcN2-83lFwAH_V6CdE1jnA5Fk9wM7lX0Xck58Z4zLT4w5OVKHY_SrufUkp8-0My3eLt5Sv6d-odXGos8dZsgG2qhHWs5LYltqTVBGSucd8-oDEd81VKPXLpPhKTox7uCllFSxOAjz4WtTKpA',
              ),

              const SizedBox(height: 20),

              // Warm Note / Literary Quote Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -15,
                      child: Icon(
                        Icons.format_quote,
                        size: 80,
                        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.7),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            size: 22,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '“Setiap lembar adalah jendela wawasan baru.”',
                                  style: AppTypography.titleMd.copyWith(
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Jangan lupa tinggalkan ulasan untuk membantu pembaca lainnya menemukan bacaan terbaik.',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bottom Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka formulir ulasan buku...'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Beri Ulasan Buku',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: AppColors.secondaryFixed,
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kembali ke Beranda',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
