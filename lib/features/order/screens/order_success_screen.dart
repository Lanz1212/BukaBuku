import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/order_model.dart';
import '../models/order_simulation_flow.dart';
import '../widgets/order_flow_panel.dart';
import '../widgets/order_simulation_tabs.dart';
import '../widgets/order_success_summary_card.dart';
import '../widgets/order_timeline_stepper.dart';
import 'order_detail_screen.dart';

/// Halaman Pesanan Berhasil Dibuat (Konfirmasi Pesanan)
/// Conforms to DESIGN.md, AppColors, AppTypography, and Stitch screen ecf4c766eb544d318976098afeb67cee.
class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final OrderSimulationFlow initialFlow;
  final VoidCallback? onViewOrderDetails;
  final VoidCallback? onBackToHome;

  const OrderSuccessScreen({
    super.key,
    this.orderId = '#ORD00125',
    this.initialFlow = OrderSimulationFlow.pickupCash,
    this.onViewOrderDetails,
    this.onBackToHome,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late OrderSimulationFlow _selectedFlow;

  @override
  void initState() {
    super.initState();
    _selectedFlow = widget.initialFlow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. Top Header Bar: Konfirmasi Pesanan & Badge Budi Express
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_stories,
                        size: 20,
                        color: AppColors.primaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Konfirmasi Pesanan',
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Budi Express',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Interactive Flow Switcher Tabs (Antar Rumah, Ambil Online, Bayar Kasir)
              OrderSimulationTabs(
                selectedFlow: _selectedFlow,
                onFlowChanged: (flow) {
                  setState(() {
                    _selectedFlow = flow;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 3. Hero Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pesanan Berhasil Dibuat!',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Text(
                        'Nomor pesananmu telah tercatat di sistem Toko Buku Budi.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Order Summary Card
              OrderSuccessSummaryCard(
                orderId: widget.orderId,
                purchaseDate: '12 Mei 2024',
                itemCountLabel: '2 Buku Fisik',
                flow: _selectedFlow,
              ),

              const SizedBox(height: 16),

              // 5. Dynamic Flow Specific Panel (Delivery / Store Pickup / Cashier QR)
              OrderFlowPanel(
                flow: _selectedFlow,
                orderId: widget.orderId,
              ),

              const SizedBox(height: 16),

              // 6. Next Steps Timeline Stepper
              OrderTimelineStepper(
                flow: _selectedFlow,
              ),

              const SizedBox(height: 24),

              // 7. Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.onViewOrderDetails != null) {
                      widget.onViewOrderDetails!();
                    } else {
                      final targetOrder = mockOrders.firstWhere(
                        (o) => o.id == widget.orderId,
                        orElse: () => mockOrders.first,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: targetOrder),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                child: TextButton(
                  onPressed: () {
                    if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                    } else {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
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
    );
  }
}
