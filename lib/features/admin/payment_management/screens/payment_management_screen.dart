import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/models/payment_monthly_summary.dart';
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
  List<PaymentTransaction> _transactions = [];
  PaymentMonthlySummary? _summary;
  bool _isLoading = true;

  late int _selectedYear;
  late int _selectedMonth;
  RealtimeChannel? _realtimeChannel;

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;

    _loadData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = PaymentService.subscribeToPayments(
      onData: () {
        if (mounted) {
          _loadData(showLoadingIndicator: false);
        }
      },
    );
  }

  Future<void> _loadData({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        PaymentService.fetchMonthlyTransactions(
          year: _selectedYear,
          month: _selectedMonth,
        ),
        PaymentService.fetchMonthlySummary(
          year: _selectedYear,
          month: _selectedMonth,
        ),
      ]);

      if (mounted) {
        setState(() {
          _transactions = results[0] as List<PaymentTransaction>;
          _summary = results[1] as PaymentMonthlySummary;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading payment data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPreviousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadData();
  }

  void _onNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadData();
  }

  String get _monthDisplayText {
    final m = (_selectedMonth >= 1 && _selectedMonth <= 12)
        ? _monthNames[_selectedMonth - 1]
        : '';
    final short = m.length > 3 ? m.substring(0, 3) : m;
    return '$short $_selectedYear';
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return now.year == _selectedYear && now.month == _selectedMonth;
  }

  int get _cashCount => _summary?.pendingCashCount ?? 0;

  List<PaymentTransaction> get _filteredTransactions {
    switch (_selectedFilter) {
      case PaymentFilter.all:
        return _transactions;
      case PaymentFilter.cash:
        // Menampilkan semua transaksi dengan metode tunai kasir
        return _transactions
            .where((t) => t.method == PaymentMethod.cashPickup)
            .toList();
      case PaymentFilter.paid:
        return _transactions
            .where((t) => t.status == PaymentStatus.paid)
            .toList();
      case PaymentFilter.pending:
        return _transactions
            .where((t) =>
                t.status == PaymentStatus.pending ||
                t.status == PaymentStatus.needsConfirmation)
            .toList();
    }
  }

  Future<void> _handleCashConfirmed(
    PaymentTransaction tx,
    int receivedAmount,
    int changeAmount,
  ) async {
    // Tampilkan snackbar proses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menyimpan konfirmasi pembayaran tunai ${tx.orderId}...'),
        duration: const Duration(seconds: 1),
      ),
    );

    final success = await PaymentService.confirmCashPayment(
      rawOrderId: tx.rawOrderId,
      totalAmount: tx.total,
      receivedAmount: receivedAmount,
      changeAmount: changeAmount,
      customerName: tx.customerName,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pembayaran tunai ${tx.orderId} senilai ${tx.formattedTotal} berhasil dikonfirmasi!',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Reload data langsung
      _loadData(showLoadingIndicator: false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengonfirmasi pembayaran tunai ${tx.orderId}. Coba lagi nanti.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            if (tx.time.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Waktu Transaksi: ${tx.time}',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            if (tx.bookTitles.isNotEmpty) ...[
              Text(
                'Rincian Buku Dibeli:',
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              ...tx.bookTitles.map(
                (title) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
            ],
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
                    content: Text('Mempersiapkan bukti pembayaran invoice...'),
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
          'Memeriksa status pembayaran pesanan ${tx.orderId}...',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredTransactions;

    final totalKas = _summary?.totalAmount ?? 0;
    final cashKas = _summary?.cashAmount ?? 0;
    final midtransKas = _summary?.midtransAmount ?? 0;
    final paidCount = _summary?.totalPaidTransactions ?? 0;

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
          'Pembayaran & Kas',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryContainer),
            onPressed: () => _loadData(),
            tooltip: 'Segarkan Data',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadData(showLoadingIndicator: false),
          color: AppColors.primaryContainer,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subtitle
                Text(
                  'Kelola arus kas bulanan real-time dari database. Pembayaran kasir masuk Tunai Kasir dan transaksi online masuk Midtrans.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Arus Kas Bulanan Card
                PaymentCashSummary(
                  totalAmount: totalKas,
                  cashAmount: cashKas,
                  midtransAmount: midtransKas,
                  monthText: _monthDisplayText,
                  paidCount: paidCount,
                  isCurrentMonth: _isCurrentMonth,
                  isLoading: _isLoading,
                  onPreviousMonth: _onPreviousMonth,
                  onNextMonth: _onNextMonth,
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
                if (_isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  )
                else if (list.isEmpty)
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
                            'Tidak ada transaksi pada periode/kategori ini',
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
                        onCashConfirmed: (received, change) =>
                            _handleCashConfirmed(tx, received, change),
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
      ),
    );
  }
}
