import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PaymentSuccessItem {
  final String title;
  final String subtitle;
  final String price;
  final String imageUrl;

  const PaymentSuccessItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
  });
}

/// Bento-style transaction card displaying total payment, order metadata,
/// purchased book items, and home delivery destination info.
class PaymentSuccessBentoCard extends StatefulWidget {
  final int totalAmount;
  final String orderId;
  final String paymentTime;
  final String paymentMethod;
  final List<PaymentSuccessItem> books;
  final String deliveryTitle;
  final String deliveryAddress;

  const PaymentSuccessBentoCard({
    super.key,
    this.totalAmount = 181000,
    this.orderId = '#ORD00125',
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
  });

  @override
  State<PaymentSuccessBentoCard> createState() =>
      _PaymentSuccessBentoCardState();
}

class _PaymentSuccessBentoCardState extends State<PaymentSuccessBentoCard> {
  bool _isCopied = false;

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString().split('').reversed.join('')}';
  }

  void _copyOrderId() {
    Clipboard.setData(ClipboardData(text: widget.orderId));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nomor Pesanan ${widget.orderId} berhasil disalin!'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Amount Highlight Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PEMBAYARAN',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRupiah(widget.totalAmount),
                    style: AppTypography.headlineLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primaryContainer,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          const SizedBox(height: 14),

          // 2. Metadata Rows
          _buildMetaRow(
            label: 'Nomor Pesanan',
            customValueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.orderId,
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: _copyOrderId,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      _isCopied ? Icons.check_circle : Icons.content_copy,
                      size: 16,
                      color: _isCopied ? AppColors.success : AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildMetaRow(
            label: 'Waktu Pembayaran',
            value: widget.paymentTime,
          ),
          const SizedBox(height: 10),
          _buildMetaRow(
            label: 'Metode Pembayaran',
            value: widget.paymentMethod,
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          const SizedBox(height: 14),

          // 3. Books Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RINCIAN BUKU (${widget.books.length})',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Paket Kurir Terproteksi',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 4. Book Items List
          ...widget.books.map((book) => _buildBookItemTile(book)),

          const SizedBox(height: 12),

          // 5. Delivery Details Block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.deliveryTitle,
                        style: AppTypography.titleMd.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.deliveryAddress,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
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
    );
  }

  Widget _buildMetaRow({
    required String label,
    String? value,
    Widget? customValueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        if (customValueWidget != null)
          customValueWidget
        else
          Text(
            value ?? '',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildBookItemTile(PaymentSuccessItem book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Book Thumbnail with Fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 38,
              height: 52,
              child: Image.network(
                book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.book_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: AppTypography.titleMd.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  book.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Price Tag
          Text(
            book.price,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
