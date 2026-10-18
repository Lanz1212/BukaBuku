import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../cart/models/cart_item.dart';
import '../models/checkout_order.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/checkout_delivery_address_card.dart';
import '../widgets/checkout_fulfillment_selector.dart';
import '../widgets/checkout_order_summary.dart';
import '../widgets/checkout_payment_selector.dart';
import '../widgets/checkout_payment_summary.dart';
import '../widgets/checkout_store_pickup_card.dart';
import '../widgets/checkout_success_sheet.dart';

/// Checkout Screen for Toko Buku Budi
/// Follows DESIGN.md, AppColors, AppTypography, and Stitch Toko Buku Budi Mobile UI.
class CheckoutScreen extends StatefulWidget {
  final List<CartItem> checkoutItems;

  const CheckoutScreen({
    super.key,
    required this.checkoutItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  FulfillmentMode _fulfillmentMode = FulfillmentMode.delivery;
  DeliveryAddress _deliveryAddress = const DeliveryAddress();
  final StoreInfo _storeInfo = const StoreInfo();
  PaymentMethodOption _selectedPayment = PaymentMethodOption.allOptions.first;

  int get _subtotal => widget.checkoutItems.fold(
        0,
        (sum, item) => sum + (item.priceValue * item.quantity),
      );

  int get _totalBookCount => widget.checkoutItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  int get _shippingFee =>
      _fulfillmentMode == FulfillmentMode.delivery ? 12000 : 0;

  static const int _serviceFee = 1000;

  int get _totalPayment => _subtotal + _shippingFee + _serviceFee;

  void _onEditAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final addressController =
            TextEditingController(text: _deliveryAddress.address);
        final notesController =
            TextEditingController(text: _deliveryAddress.notes);

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubah Alamat Pengiriman',
                style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  labelStyle: AppTypography.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Catatan untuk Kurir',
                  labelStyle: AppTypography.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _deliveryAddress = DeliveryAddress(
                        recipientName: _deliveryAddress.recipientName,
                        phone: _deliveryAddress.phone,
                        address: addressController.text.trim(),
                        notes: notesController.text.trim(),
                      );
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Simpan Alamat', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openMapNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membuka rute ke Toko Buku Budi Cikini di Maps...'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _submitOrder() {
    final randomId = '#TBB-${10000 + Random().nextInt(89999)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSuccessSheet(
        orderId: randomId,
        totalAmount: _totalPayment,
        fulfillmentMode: _fulfillmentMode,
        paymentMethod: _selectedPayment,
        onBackToHome: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: BookstoreAppBar(
        title: 'Checkout',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).maybePop(),
        onProfilePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Membuka profil akun pembaca...'),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Step Tag & Header Title
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_mall_outlined,
                            size: 14,
                            color: AppColors.onSecondaryContainer,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Langkah Terakhir',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Selesaikan Pesanan',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Periksa kembali detail buku dan tujuan pengantaran Anda.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 1. Order Summary Accordion Card
                    CheckoutOrderSummary(
                      items: widget.checkoutItems,
                      subtotalValue: _subtotal,
                    ),

                    const SizedBox(height: 20),

                    // 2. Fulfillment Mode Selector (Antar ke Rumah vs Ambil di Toko)
                    CheckoutFulfillmentSelector(
                      selectedMode: _fulfillmentMode,
                      onModeChanged: (mode) {
                        setState(() {
                          _fulfillmentMode = mode;
                          // If switching from pickup to delivery while Cash was selected, fallback to QRIS
                          if (mode == FulfillmentMode.delivery &&
                              _selectedPayment.id == 'cash') {
                            _selectedPayment = PaymentMethodOption.allOptions.first;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // 3. Conditional Details Card (Address vs Store Info)
                    if (_fulfillmentMode == FulfillmentMode.delivery)
                      CheckoutDeliveryAddressCard(
                        address: _deliveryAddress,
                        onEditAddress: _onEditAddress,
                      )
                    else
                      CheckoutStorePickupCard(
                        storeInfo: _storeInfo,
                        onOpenMap: _openMapNotice,
                      ),

                    const SizedBox(height: 20),

                    // 4. Payment Method Selector Card
                    CheckoutPaymentSelector(
                      selectedPayment: _selectedPayment,
                      fulfillmentMode: _fulfillmentMode,
                      onPaymentChanged: (payment) {
                        setState(() {
                          _selectedPayment = payment;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // 5. Payment Cost Breakdown Card
                    CheckoutPaymentSummary(
                      itemCount: _totalBookCount,
                      subtotalValue: _subtotal,
                      fulfillmentMode: _fulfillmentMode,
                      shippingFee: _shippingFee,
                      serviceFee: _serviceFee,
                      totalPayment: _totalPayment,
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // 6. Sticky Bottom Order Bar
            CheckoutBottomBar(
              totalAmount: _totalPayment,
              onSubmitOrder: _submitOrder,
            ),
          ],
        ),
      ),
    );
  }
}
