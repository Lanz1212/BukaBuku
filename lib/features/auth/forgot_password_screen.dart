import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';


/// Forgot Password Page — Toko Buku Budi
/// Design: DESIGN.md | AppColors | AppTypography
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailSent = false;
  int _countdown = 60;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ─── Shared helpers ─────────────────────────────────────────────────────────

  OutlineInputBorder _border({
    Color color = AppColors.outlineVariant,
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.outline),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder:
            _border(color: AppColors.primaryContainer, width: 1.5),
        errorBorder: _border(color: AppColors.error),
        focusedErrorBorder:
            _border(color: AppColors.error, width: 1.5),
      );

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              _buildLogo(),
              const SizedBox(height: 20),
              _buildHeading(),
              const SizedBox(height: 28),
              if (!_isEmailSent) _buildEmailField(),
              if (_isEmailSent) _buildSuccessMessage(),
              const SizedBox(height: 24),
              if (!_isEmailSent) _buildSendButton(),
              if (_isEmailSent) _buildResendButton(),
              const SizedBox(height: 28),
              _buildBackToLoginPrompt(),
              const SizedBox(height: 20),
              _buildTrustBadge(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.maybePop(context),
      ),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/Logo Toko Buku Budi.png',
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.auto_stories,
                size: 24,
                color: AppColors.secondary,
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Lupa Password',
            style: AppTypography.titleMd,
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ClipOval(
            child: Image.asset(
              'assets/images/Profile.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── App Logo ────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_reset,
          size: 40,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // ─── Heading ─────────────────────────────────────────────────────────────────

  Widget _buildHeading() {
    return Column(
      children: [
        Text(
          'Bantuan Akun',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Lupa Password?',
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Masukkan email yang terdaftar untuk\nmendapatkan instruksi reset password.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Email Field ─────────────────────────────────────────────────────────────

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat Email Terdaftar',
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: _inputDecoration(
            hint: 'nama@email.com',
            prefixIcon: Icons.mail_outline_rounded,
          ),
        ),
      ],
    );
  }

  // ─── Success Message ───────────────────────────────────────────────────────────

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read,
            size: 48,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Instruksi Terkirim',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami telah mengirimkan tautan pemulihan\nkata sandi ke email Anda.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan periksa kotak masuk atau folder spam.',
            style: AppTypography.caption.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Send Button ─────────────────────────────────────────────────────────────

  Widget _buildSendButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isEmailSent = true;
            _startCountdown();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kirim Instruksi',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.send_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Resend Button ────────────────────────────────────────────────────────────

  Widget _buildResendButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _countdown == 0
            ? () {
                setState(() {
                  _countdown = 60;
                  _startCountdown();
                });
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _countdown == 0
              ? AppColors.primaryContainer
              : AppColors.surfaceContainer,
          foregroundColor: _countdown == 0
              ? AppColors.onPrimary
              : AppColors.onSurfaceVariant,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _countdown > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Kirim ulang dalam $_countdown detik',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kirim Ulang',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.refresh_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  // ─── Back to Login Prompt ─────────────────────────────────────────────────────

  Widget _buildBackToLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.arrow_back,
          size: 16,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        _AnimatedClickText(
          text: 'Kembali ke Halaman Masuk',
          onTap: () {
            Navigator.pop(context);
          },
          isBold: true,
        ),
      ],
    );
  }

  // ─── Trust Badge ──────────────────────────────────────────────────────────────

  Widget _buildTrustBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Toko Buku Budi • 100% Buku Asli & Bergaransi',
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Click Text Widget ─────────────────────────────────────────────────

class _AnimatedClickText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isBold;

  const _AnimatedClickText({
    required this.text,
    required this.onTap,
    this.isBold = false,
  });

  @override
  State<_AnimatedClickText> createState() => _AnimatedClickTextState();
}

class _AnimatedClickTextState extends State<_AnimatedClickText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    _controller.forward();
  }

  void _handleTapUp() {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) {
          _handleTapUp();
          widget.onTap();
        },
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.surfaceContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Text(
                    widget.text,
                    style: AppTypography.bodyMd.copyWith(
                      color: _isHovered
                          ? AppColors.primaryContainer
                          : AppColors.secondary,
                      fontWeight: widget.isBold ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
