import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/payment_transaction.dart';

class PaymentConfirmCashSheet extends StatefulWidget {
  final PaymentTransaction transaction;
  final VoidCallback onConfirmed;

  const PaymentConfirmCashSheet({
    super.key,
    required this.transaction,
    required this.onConfirmed,
  });

  @override
  State<PaymentConfirmCashSheet> createState() => _PaymentConfirmCashSheetState();
}

class _PaymentConfirmCashSheetState extends State<PaymentConfirmCashSheet> {
  late TextEditingController _controller;
  int _receivedAmount = 0;

  @override
  void initState() {
    super.initState();
    _receivedAmount = widget.transaction.total;
    _controller = TextEditingController(text: _receivedAmount.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatPrice(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    final int change = _receivedAmount - widget.transaction.total;
    final bool isValid = _receivedAmount >= widget.transaction.total;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konfirmasi Pembayaran Tunai',
                        style: AppTypography.titleMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${widget.transaction.orderId} • ${widget.transaction.customerName}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nominal Tagihan',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    widget.transaction.formattedTotal,
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryContainer,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Uang Diterima dari Pelanggan',
              style: AppTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 8),
            // Quick Amount Buttons
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildQuickButton(
                  label: 'Uang Pas',
                  amount: widget.transaction.total,
                ),
                _buildQuickButton(
                  label: _formatPrice(widget.transaction.total + 40000),
                  amount: widget.transaction.total + 40000,
                ),
                _buildQuickButton(
                  label: _formatPrice(widget.transaction.total + 90000),
                  amount: widget.transaction.total + 90000,
                ),
                _buildQuickButton(
                  label: 'Rp500.000',
                  amount: 500000,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val) ?? 0;
                setState(() {
                  _receivedAmount = parsed;
                });
              },
            ),
            const SizedBox(height: 12),
            // Kembalian Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isValid
                    ? AppColors.surfaceContainerHigh
                    : AppColors.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isValid ? 'Kembalian' : 'Uang Kurang',
                    style: AppTypography.bodyMd.copyWith(
                      color: isValid ? AppColors.onSurfaceVariant : AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    isValid
                        ? _formatPrice(change)
                        : '-${_formatPrice(widget.transaction.total - _receivedAmount)}',
                    style: AppTypography.labelLg.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isValid ? AppColors.success : AppColors.error,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: isValid
                  ? () {
                      Navigator.pop(context);
                      widget.onConfirmed();
                    }
                  : null,
              child: Text(
                'Konfirmasi & Terima Pembayaran',
                style: AppTypography.labelLg.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton({
    required String label,
    required int amount,
  }) {
    final bool isSelected = _receivedAmount == amount;
    return InkWell(
      onTap: () {
        setState(() {
          _receivedAmount = amount;
          _controller.text = amount.toString();
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
