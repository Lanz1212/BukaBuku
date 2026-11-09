import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../admin/shared/screens/admin_main_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';
import 'services/auth_service.dart';
import '../../core/services/cashier_log_service.dart';

/// Login Page — Toko Buku Budi
/// Design: DESIGN.md | AppColors | AppTypography
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildRememberMe(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 28),
              _buildSignUpPrompt(),
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
            'Login',
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
          'Selamat Datang Kembali',
          style: AppTypography.headlineLg.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Masuk untuk melanjutkan pengalaman\n'
          'belanja buku favoritmu di Toko Buku Budi.',
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
          'Email',
          style: AppTypography.labelMd.copyWith(color: AppColors.onSurface),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: _inputDecoration(
            hint: 'pembaca@tokobukubudi.id',
            prefixIcon: Icons.mail_outline_rounded,
          ),
        ),
      ],
    );
  }

  // ─── Password Field ───────────────────────────────────────────────────────────

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kata Sandi',
              style:
                  AppTypography.labelMd.copyWith(color: AppColors.onSurface),
            ),
            _AnimatedClickText(
              text: 'Lupa Password?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: _inputDecoration(
            hint: 'bukuklasik123',
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Icon(
                  _obscurePassword
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

  // ─── Remember Me ─────────────────────────────────────────────────────────────

  Widget _buildRememberMe() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: AppColors.onSurface,
            checkColor: AppColors.surface,
            side: BorderSide(
              color: _rememberMe ? AppColors.onSurface : AppColors.outline,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Ingat saya di perangkat ini',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
        ),
      ],
    );
  }

  // ─── Login Actions & Validation ─────────────────────────────────────────────

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'Email atau kata sandi tidak sesuai.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum diverifikasi. Silakan periksa kotak masuk email Anda.';
    }
    if (lower.contains('too many requests')) {
      return 'Terlalu banyak percobaan masuk. Coba lagi beberapa saat.';
    }
    return 'Gagal masuk: $message';
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan kata sandi wajib diisi.');
      return;
    }

    if (!email.contains('@')) {
      _showError('Format email tidak valid.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.signIn(email: email, password: password);

      // Ambil role akun dari profiles
      final role = await AuthService.getCurrentUserRole();

      if (!mounted) return;

      if (role == 'admin') {
        CashierLogService.clearCachedAdminName();
        CashierLogService.recordLog(
          action: 'Buka Sesi Kasir / Admin',
          details: 'Admin berhasil masuk ke panel kasir & toko',
          tag: 'Shift',
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      _showError(_translateAuthError(e.message));
    } catch (e) {
      _showError('Terjadi kesalahan saat masuk: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ─── Login Button ─────────────────────────────────────────────────────────────

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Masuk ke Akun',
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

  // ─── Sign-up Prompt ───────────────────────────────────────────────────────────

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?  ',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        _AnimatedClickText(
          text: 'Daftar sekarang',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          isBold: true,
        ),
      ],
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

