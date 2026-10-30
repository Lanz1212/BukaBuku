import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/payment_transaction.dart';
import '../widgets/payment_cash_summary.dart';
import '../widgets/payment_filter_tabs.dart';
import '../widgets/payment_transaction_card.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  PaymentFilter _selectedFilter = PaymentFilter.all;
  late List<PaymentTransaction> _transactions;

  int _totalAmount = 2350000;
  int _cashAmount = 460000;
  final int _onlineAmount = 1890000;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(PaymentTransaction.mockTransactions);
  }

  int get _cashCount => _transactions
      .where((t) => t.status == PaymentStatus.needsConfirmation)
      .length;

  List<PaymentTransaction> get _filteredTransactions {
    switch (_selectedFilter) {
      case PaymentFilter.all:
        return _transactions;
      case PaymentFilter.cash:
        return _transactions
            .where((t) =>
                t.method == PaymentMethod.cashPickup ||
                t.status == PaymentStatus.needsConfirmation)
            .toList();
      case PaymentFilter.paid:
        return _transactions
            .where((t) => t.status == PaymentStatus.paid)
            .toList();
      case PaymentFilter.pending:
        return _transactions
            .where((t) => t.status == PaymentStatus.pending)
            .toList();
    }
  }

  void _handleCashConfirmed(PaymentTransaction tx) {
    setState(() {
      final index = _transactions.indexWhere((t) => t.orderId == tx.orderId);
      if (index != -1) {
        _transactions[index] = PaymentTransaction(
          orderId: tx.orderId,
          time: 'Hari ini, Baru saja',
          customerName: tx.customerName,
          customerPhone: tx.customerPhone,
          status: PaymentStatus.paid,
          method: tx.method,
          methodLabel: 'Cash Kasir (Lunas)',
          total: tx.total,
          bookTitles: tx.bookTitles,
          deliveryType: tx.deliveryType,
        );
        _totalAmount += tx.total;
        _cashAmount += tx.total;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pembayaran tunai ${tx.orderId} senilai ${tx.formattedTotal} berhasil dikonfirmasi!',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInvoice(PaymentTransaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice ${tx.orderId}',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pelanggan: ${tx.customerName} (${tx.customerPhone})',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Metode Pembayaran: ${tx.methodLabel}',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Tagihan',
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tx.formattedTotal,
                  style: AppTypography.titleMd.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mengunduh bukti pembayaran invoice...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Unduh PDF Bukti Bayar'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkStatus(PaymentTransaction tx) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memeriksa gateway pembayaran untuk pesanan ${tx.orderId}...',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF9F5),
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Pembayaran',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primaryContainer,
              child: const Text(
                'K1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subtitle
              Text(
                'Kelola penerimaan transaksi kasir dan konfirmasi pembayaran tunai secara real-time.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Arus Kas Hari Ini Card
              PaymentCashSummary(
                totalAmount: _totalAmount,
                cashAmount: _cashAmount,
                onlineAmount: _onlineAmount,
                dateText: '12 Mei 2024',
              ),
              const SizedBox(height: 18),

              // Filter Tabs
              PaymentFilterTabs(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                cashCount: _cashCount,
              ),
              const SizedBox(height: 16),

              // Transactions List
              if (list.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tidak ada transaksi pada kategori ini',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = list[index];
                    return PaymentTransactionCard(
                      transaction: tx,
                      onCashConfirmed: () => _handleCashConfirmed(tx),
                      onShowInvoice: _showInvoice,
                      onCheckStatus: _checkStatus,
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
