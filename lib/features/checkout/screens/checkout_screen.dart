import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../../admin/store_settings/services/store_settings_service.dart';
import '../../auth/services/auth_service.dart';
import '../../cart/models/cart_item.dart';
import '../../admin/order_management/models/admin_order_detail.dart';
import '../models/checkout_order.dart';
import '../widgets/checkout_bottom_bar.dart';
import '../widgets/checkout_delivery_address_card.dart';
import '../widgets/checkout_fulfillment_selector.dart';
import '../widgets/checkout_order_summary.dart';
import '../widgets/checkout_payment_selector.dart';
import '../widgets/checkout_payment_summary.dart';
import '../widgets/checkout_store_pickup_card.dart';
import '../../order/screens/order_success_screen.dart';
import '../../order/models/order_simulation_flow.dart';
import '../../payment/screens/midtrans_snap_screen.dart';
import '../../../core/services/midtrans_service.dart';

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
  StoreInfo _storeInfo = const StoreInfo();
  PaymentMethodOption _selectedPayment = PaymentMethodOption.allOptions.first;
  String? _userId;
  String? _userEmail;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadStoreSettings();
  }

  Future<void> _loadStoreSettings() async {
    try {
      final settings = await StoreSettingsService.fetchStoreSettings();
      if (mounted) {
        setState(() {
          _storeInfo = StoreInfo(
            name: settings.storeName,
            badge: settings.branchName,
            address: settings.fullAddress,
            operatingHours: '${settings.openTime} – ${settings.closeTime}',
            phone: settings.phoneNumber.isNotEmpty
                ? settings.phoneNumber
                : settings.whatsappNumber,
            mapImageUrl: _storeInfo.mapImageUrl,
          );
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.getCurrentUserProfile();
      if (profile != null && mounted) {
        final fullName = (profile['full_name'] as String?)?.trim();
        final phone = (profile['phone'] as String?)?.trim();
        final email = (profile['email'] as String?)?.trim();
        final rawAddresses = (profile['addresses'] as String?)?.trim();

        String resolvedAddress = _deliveryAddress.address;
        if (rawAddresses != null && rawAddresses.isNotEmpty) {
          if (rawAddresses.startsWith('[')) {
            try {
              final decoded = jsonDecode(rawAddresses);
              if (decoded is List && decoded.isNotEmpty) {
                final primary = decoded.firstWhere(
                  (item) => item['isPrimary'] == true,
                  orElse: () => decoded.first,
                );
                resolvedAddress = primary['fullAddress']?.toString() ?? resolvedAddress;
              }
            } catch (_) {
              resolvedAddress = rawAddresses;
            }
          } else {
            resolvedAddress = rawAddresses;
          }
        }

        setState(() {
          _userId = profile['id'] as String?;
          _userEmail = (email != null && email.isNotEmpty)
              ? email
              : AuthService.currentUser?.email;
          _deliveryAddress = DeliveryAddress(
            recipientName: (fullName != null && fullName.isNotEmpty)
                ? fullName
                : _deliveryAddress.recipientName,
            phone: (phone != null && phone.isNotEmpty)
                ? phone
                : _deliveryAddress.phone,
            address: resolvedAddress,
            notes: _deliveryAddress.notes,
          );
        });
        return;
      }

      // Fallback: Ambil data user dari tabel profiles di Supabase
      SupabaseClient? client;
      try {
        client = Supabase.instance.client;
      } catch (_) {
        client = null;
      }

      if (client == null) return;

      final defaultProfile = await client
          .from('profiles')
          .select()
          .eq('role', 'user')
          .limit(1)
          .maybeSingle();

      if (defaultProfile != null && mounted) {
        final fullName = (defaultProfile['full_name'] as String?)?.trim();
        final phone = (defaultProfile['phone'] as String?)?.trim();
        final email = (defaultProfile['email'] as String?)?.trim();
        final addresses = (defaultProfile['addresses'] as String?)?.trim();

        setState(() {
          _userId = defaultProfile['id'] as String?;
          _userEmail = (email != null && email.isNotEmpty)
              ? email
              : AuthService.currentUser?.email;
          _deliveryAddress = DeliveryAddress(
            recipientName: fullName ?? 'Budi Santoso',
            phone: phone ?? '081234567890',
            address: addresses ?? 'Jl. Cikini Raya No. 10, Jakarta Pusat',
            notes: 'Titipkan di meja resepsionis jika tidak di tempat.',
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile in checkout: $e');
    }
  }

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

  void _openPaymentMethodScreen() {
    // Dengan 2 pilihan metode (Midtrans & Kasir), pemilihan langsung dilakukan di kartu checkout
  }

  void _showMidtransSetupHelpDialog(String errorMessage, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Gagal Membuka Midtrans',
              style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan #$orderId tercatat dengan status Menunggu Pembayaran, namun halaman Midtrans gagal dimuat.',
              style: AppTypography.bodyMd.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Detail kendala:\n$errorMessage',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final itemsData = widget.checkoutItems.map((item) {
        return {
          'book_id': item.bookId,
          'title': item.title,
          'author': item.author,
          'quantity': item.quantity,
          'price': item.priceValue,
          'rack_location': item.storeLocation,
          'image_url': item.coverUrl,
        };
      }).toList();

      final isDelivery = _fulfillmentMode == FulfillmentMode.delivery;
      final deliveryType =
          isDelivery ? 'Kurir Toko (Delivery)' : 'Ambil di Toko (Pickup)';
      final isCash = _selectedPayment.id == 'cash';
      final paymentMethod = isCash ? 'Bayar di Kasir' : 'Midtrans Payment Gateway';

      final pickupCode = isDelivery
          ? null
          : 'PU-${(DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}-${(DateTime.now().second * 17 % 1000).toString().padLeft(3, '0')}';

      // 1. Simpan pesanan ke database Supabase
      final createdOrder = await OrderService.createOrder(
        userId: _userId,
        customerName: _deliveryAddress.recipientName,
        customerPhone: _deliveryAddress.phone,
        customerAddress:
            isDelivery ? _deliveryAddress.address : _storeInfo.address,
        deliveryType: deliveryType,
        paymentMethod: paymentMethod,
        paymentChannel: _selectedPayment.subtitle,
        isPaid: false,
        status: AdminOrderStatus.baru,
        totalPrice: _totalPayment,
        shippingFee: _shippingFee,
        serviceFee: _serviceFee,
        specialNote: _deliveryAddress.notes,
        pickupCode: pickupCode,
        pickupPoint: isDelivery ? null : 'Gerai Utama Cikini, Meja Kasir 1',
        accountAddress: _deliveryAddress.address,
        items: itemsData,
      );

      // Bersihkan keranjang belanja
      try {
        final cartIds = widget.checkoutItems
            .map((i) => i.id)
            .where((id) => !id.startsWith('item-') && !id.startsWith('temp-'))
            .toList();
        if (cartIds.isNotEmpty) {
          await CartService.removeCartItems(cartIds);
        }
      } catch (_) {}

      if (!mounted) return;

      // ─── KASUS 1: BAYAR DI KASIR ──────────────────────────────────
      if (isCash) {
        // Langsung berhasil dibuat dan menuju ke konfirmasi pesanan
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(
              orderId: '#${createdOrder.orderId}',
              initialFlow: OrderSimulationFlow.pickupCash,
            ),
          ),
        );
        return;
      }

      // ─── KASUS 2: BAYAR VIA MIDTRANS ──────────────────────────────
      try {
        // Bangun item_details untuk Midtrans — gross_amount HARUS sama dengan sum(item_details)
        final midtransItems = List<Map<String, dynamic>>.from(itemsData);

        // Tambahkan ongkos kirim sebagai item jika ada
        if (_shippingFee > 0) {
          midtransItems.add({
            'book_id': 'SHIPPING',
            'title': 'Ongkos Kirim (Kurir Toko)',
            'quantity': 1,
            'price': _shippingFee,
          });
        }

        // Tambahkan biaya layanan sebagai item jika ada
        if (_serviceFee > 0) {
          midtransItems.add({
            'book_id': 'SERVICE_FEE',
            'title': 'Biaya Layanan',
            'quantity': 1,
            'price': _serviceFee,
          });
        }

        // Request Snap Token via Edge Function / Midtrans API
        final snapResponse = await MidtransService.createSnapToken(
          orderId: createdOrder.orderId,
          amount: _totalPayment,
          customerName: _deliveryAddress.recipientName,
          customerEmail: _userEmail ?? AuthService.currentUser?.email,
          customerPhone: _deliveryAddress.phone,
          items: midtransItems,
        );

        if (!mounted) return;

        // Buka WebView Snap Midtrans
        final paymentResult = await Navigator.of(context).push<MidtransPaymentResult>(
          MaterialPageRoute(
            builder: (context) => MidtransSnapScreen(
              snapToken: snapResponse.token,
              redirectUrl: snapResponse.redirectUrl,
              orderId: createdOrder.orderId,
              totalAmount: _totalPayment,
            ),
          ),
        );

        if (!mounted) return;

        if (paymentResult == MidtransPaymentResult.success) {
          // Pembayaran berhasil! Update status pesanan di Supabase
          await OrderService.updateMidtransPaymentData(
            orderId: createdOrder.orderId,
            isPaid: true,
            snapToken: snapResponse.token,
            transactionStatus: 'settlement',
            newStatus: AdminOrderStatus.diproses,
          );

          if (!mounted) return;

          final successFlow = isDelivery
              ? OrderSimulationFlow.delivery
              : OrderSimulationFlow.pickupOnline;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderId: '#${createdOrder.orderId}',
                initialFlow: successFlow,
              ),
            ),
          );
        } else if (paymentResult == MidtransPaymentResult.pending) {
          // Pembayaran pending (misal menunggu transfer VA)
          await OrderService.updateMidtransPaymentData(
            orderId: createdOrder.orderId,
            isPaid: false,
            snapToken: snapResponse.token,
            transactionStatus: 'pending',
          );

          if (!mounted) return;

          final successFlow = isDelivery
              ? OrderSimulationFlow.delivery
              : OrderSimulationFlow.pickupOnline;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan dibuat. Menunggu penyelesaian pembayaran Midtrans.'),
              backgroundColor: AppColors.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderId: '#${createdOrder.orderId}',
                initialFlow: successFlow,
              ),
            ),
          );
        } else {
          // Dibatalkan / ditutup oleh pembaca
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pembayaran belum diselesaikan. Anda dapat melihat pesanan #${createdOrder.orderId} di menu Pesanan Saya.',
              ),
              backgroundColor: AppColors.primaryContainer,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (midtransError) {
        debugPrint('Midtrans Token Error: $midtransError');
        if (!mounted) return;
        _showMidtransSetupHelpDialog(midtransError.toString(), createdOrder.orderId);
      }
    } catch (e) {
      debugPrint('Error creating order in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
                      onOpenPaymentMethods: _openPaymentMethodScreen,
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
