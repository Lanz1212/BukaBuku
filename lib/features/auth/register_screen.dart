import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

/// Register Page — Toko Buku Budi
/// Design: DESIGN.md | AppColors | AppTypography
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
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
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.outline),
        suffixIcon: suffixIcon,
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
              _buildFormFields(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              const SizedBox(height: 20),
              _buildOrDivider(),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 28),
              _buildLoginPrompt(),
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
            'Register',
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
      child: Image.asset(
        'assets/images/Margin.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.outlineVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Heading ─────────────────────────────────────────────────────────────────

  Widget _buildHeading() {
    return Column(
      children: [
        Text(
          'Buat Akun Baru',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Lengkapi data diri untuk menikmati kurasi\n'
          'buku istimewa dan layanan pengiriman terpercaya.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── Form Fields ─────────────────────────────────────────────────────────────

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Nama Lengkap',
          hint: 'Nama lengkap Anda',
          prefixIcon: Icons.person_outline_rounded,
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email',
          hint: 'nama@email.com',
          prefixIcon: Icons.mail_outline_rounded,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nomor HP (WhatsApp)',
          hint: '08123456789',
          prefixIcon: Icons.call_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'Kata Sandi',
          hint: 'Minimal 8 karakter',
          controller: _passwordController,
          obscureText: _obscurePassword,
          onToggle: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'Ulangi Kata Sandi',
          hint: 'Ulangi kata sandi',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          onToggle: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Alamat Pengiriman',
          hint: 'Alamat lengkap dengan kode pos',
          prefixIcon: Icons.location_on_outlined,
          controller: _addressController,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: _inputDecoration(
            hint: hint,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: _inputDecoration(
            hint: hint,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Icon(
                  obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
              activeColor: AppColors.onSurface,
              checkColor: AppColors.surface,
              side: BorderSide(
                color: _agreeToTerms ? AppColors.onSurface : AppColors.outline,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 0,
                runSpacing: 4,
                children: [
                  Text(
                    'Saya menyetujui ',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  ),
                  _AnimatedClickText(
                    text: 'Syarat & Ketentuan',
                    onTap: () {},
                  ),
                  Text(
                    ' serta ',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  ),
                  _AnimatedClickText(
                    text: 'Kebijakan Privasi',
                    onTap: () {},
                  ),
                  Text(
                    ' Toko Buku Budi.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Register Button ───────────────────────────────────────────────────────────

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to home after successful registration
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
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
              'Daftar Akun',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Or Divider ───────────────────────────────────────────────────────────────

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.outlineVariant, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau daftar lebih cepat',
            style: AppTypography.caption.copyWith(color: AppColors.outline),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.outlineVariant, thickness: 1),
        ),
      ],
    );
  }

  // ─── Google Button ────────────────────────────────────────────────────────────

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          // Handle Google sign-up
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.outlineVariant),
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Google_Logo.png',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return const _GoogleLogoWidget();
              },
            ),
            const SizedBox(width: 10),
            Text(
              'Daftar dengan Google',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Login Prompt ─────────────────────────────────────────────────────────────

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun?  ',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        _AnimatedClickText(
          text: 'Masuk',
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

// ─── Google "G" Logo ──────────────────────────────────────────────────────────

class _GoogleLogoWidget extends StatelessWidget {
  const _GoogleLogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.44;
    final sw = size.width * 0.165;
    final rect = Rect.fromCircle(center: c, radius: r);

    Paint mkArc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    const rad = math.pi / 180.0;

    // Segments drawn clockwise; gap is ~-22° to +22° on the right side.
    // Yellow — lower-right
    canvas.drawArc(rect, 22 * rad, 45 * rad, false,
        mkArc(const Color(0xFFFBBC05)));
    // Green — bottom
    canvas.drawArc(rect, 67 * rad, 113 * rad, false,
        mkArc(const Color(0xFF34A853)));
    // Blue — left + top
    canvas.drawArc(rect, 180 * rad, 112 * rad, false,
        mkArc(const Color(0xFF4285F4)));
    // Red — upper-right
    canvas.drawArc(rect, 292 * rad, 46 * rad, false,
        mkArc(const Color(0xFFEA4335)));

    // Horizontal crossbar of the G
    canvas.drawLine(
      c,
      Offset(c.dx + r + sw * 0.3, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
