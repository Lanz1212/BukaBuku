import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/midtrans_constants.dart';
import '../../../core/services/order_service.dart';

enum MidtransPaymentResult {
  success,
  pending,
  failed,
  cancelled,
}

/// Layar untuk menampilkan Snap Payment Midtrans di dalam aplikasi.
/// Mendukung WebView pada Android/iOS dan Browser Launcher pada Web/Desktop.
class MidtransSnapScreen extends StatefulWidget {
  final String snapToken;
  final String? redirectUrl;
  final String orderId;
  final int totalAmount;

  const MidtransSnapScreen({
    super.key,
    required this.snapToken,
    this.redirectUrl,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<MidtransSnapScreen> createState() => _MidtransSnapScreenState();
}

class _MidtransSnapScreenState extends State<MidtransSnapScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isCheckingStatus = false;
  String? _errorMessage;
  bool _useExternalBrowser = false;

  bool get _isWebViewSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  String get _targetUrl => widget.redirectUrl?.isNotEmpty == true
      ? widget.redirectUrl!
      : '${MidtransConstants.snapRedirectionBaseUrl}${widget.snapToken}';

  String _formatRupiah(int amount) =>
      'Rp${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void initState() {
    super.initState();
    if (_isWebViewSupported) {
      _initWebView();
    } else {
      _useExternalBrowser = true;
      _isLoading = false;
      // Otomatis buka di browser eksternal jika di web / desktop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchInBrowser();
      });
    }
  }

  Future<void> _launchInBrowser() async {
    try {
      final uri = Uri.parse(_targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching Midtrans URL: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Tidak dapat membuka browser: $e';
        });
      }
    }
  }

  void _initWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
              _checkPaymentStatusUrl(url);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
              _checkPaymentStatusUrl(url);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Midtrans WebView Error: ${error.description}');
              if (!error.description.contains('ERR_UNKNOWN_URL_SCHEME')) {
                if (mounted) {
                  setState(() {
                    _errorMessage = error.description;
                  });
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url.toLowerCase();
              debugPrint('Midtrans Navigating to: $url');

              if (url.contains('/finish') ||
                  url.contains('transaction_status=settlement') ||
                  url.contains('transaction_status=capture') ||
                  (url.contains('status_code=200') && url.contains('order_id'))) {
                _finishWithResult(MidtransPaymentResult.success);
                return NavigationDecision.prevent;
              }

              if (url.contains('status_code=201') ||
                  url.contains('/pending') ||
                  url.contains('transaction_status=pending')) {
                _finishWithResult(MidtransPaymentResult.pending);
                return NavigationDecision.prevent;
              }

              if (url.contains('status_code=202') ||
                  url.contains('/error') ||
                  url.contains('/cancel') ||
                  url.contains('transaction_status=deny') ||
                  url.contains('transaction_status=cancel') ||
                  url.contains('transaction_status=expire')) {
                _finishWithResult(MidtransPaymentResult.failed);
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_targetUrl));
    } catch (e) {
      debugPrint('WebView init failed, fallback to browser launcher: $e');
      if (mounted) {
        setState(() {
          _useExternalBrowser = true;
          _isLoading = false;
        });
        _launchInBrowser();
      }
    }
  }

  void _checkPaymentStatusUrl(String rawUrl) {
    final url = rawUrl.toLowerCase();
    // Hanya tangani jika navigasi mengarah ke callback Midtrans spesifik
    if (url.contains('/finish') ||
        (url.contains('status_code=200') && url.contains('order_id')) ||
        url.contains('transaction_status=settlement') ||
        url.contains('transaction_status=capture')) {
      _finishWithResult(MidtransPaymentResult.success);
    } else if (url.contains('status_code=201') ||
        url.contains('/pending') ||
        url.contains('transaction_status=pending')) {
      _finishWithResult(MidtransPaymentResult.pending);
    }
  }

  void _finishWithResult(MidtransPaymentResult result) {
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _checkStatusFromDatabase() async {
    setState(() => _isCheckingStatus = true);
    try {
      final order = await OrderService.fetchOrderById(widget.orderId);
      if (order != null && order.isPaid) {
        _finishWithResult(MidtransPaymentResult.success);
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isCheckingStatus = false);
      _showManualCheckDialog();
    }
  }

  void _handleCloseConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Pembayaran?',
          style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Pesanan #${widget.orderId} belum dibayar. Apakah Anda yakin ingin menutup halaman pembayaran?',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Lanjutkan Bayar',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _finishWithResult(MidtransPaymentResult.cancelled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup Pembayaran'),
          ),
        ],
      ),
    );
  }

  void _showManualCheckDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Pembayaran',
          style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda sudah menyelesaikan pembayaran melalui Midtrans?',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Belum', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _finishWithResult(MidtransPaymentResult.success);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Sudah Lunas'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleCloseConfirmation();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
            tooltip: 'Tutup',
            onPressed: _handleCloseConfirmation,
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran Midtrans',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatRupiah(widget.totalAmount)} • Enkripsi SSL 256-Bit',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isCheckingStatus ? null : _checkStatusFromDatabase,
              child: _isCheckingStatus
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Sudah Bayar?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ],
          bottom: _isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                )
              : null,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_useExternalBrowser) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  size: 38,
                  color: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Selesaikan Pembayaran',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${_formatRupiah(widget.totalAmount)}',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Nomor Pesanan: #${widget.orderId}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Halaman pembayaran Midtrans terbuka di browser Anda. Pilih metode pembayaran (QRIS, VA, E-Wallet, Kartu) lalu selesaikan transaksi.',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _launchInBrowser,
                        icon: const Icon(Icons.open_in_browser, size: 20),
                        label: const Text('Buka Ulang di Browser'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCheckingStatus ? null : _checkStatusFromDatabase,
                  icon: _isCheckingStatus
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(
                    _isCheckingStatus ? 'Memeriksa...' : 'Saya Sudah Bayar',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _handleCloseConfirmation,
                child: const Text(
                  'Batalkan Pembayaran',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Midtrans',
                style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _useExternalBrowser = true;
                    _errorMessage = null;
                  });
                  _launchInBrowser();
                },
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Buka di Browser Saja'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : const Center(child: CircularProgressIndicator());
  }
}
