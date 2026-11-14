class PaymentMonthlySummary {
  final int totalAmount; // Total kas masuk bulan ini (is_paid = true)
  final int cashAmount; // Total tunai kasir (is_paid = true)
  final int midtransAmount; // Total midtrans / non-tunai (is_paid = true)
  final int year;
  final int month;
  final int totalPaidTransactions;
  final int pendingCashCount; // Jumlah transaksi tunai kasir yang belum konfirmasi

  const PaymentMonthlySummary({
    required this.totalAmount,
    required this.cashAmount,
    required this.midtransAmount,
    required this.year,
    required this.month,
    required this.totalPaidTransactions,
    this.pendingCashCount = 0,
  });

  factory PaymentMonthlySummary.empty({required int year, required int month}) {
    return PaymentMonthlySummary(
      totalAmount: 0,
      cashAmount: 0,
      midtransAmount: 0,
      year: year,
      month: month,
      totalPaidTransactions: 0,
      pendingCashCount: 0,
    );
  }
}

