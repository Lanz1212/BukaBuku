import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/edit_profile_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile user;

  const EditProfileScreen({
    super.key,
    this.user = UserProfile.defaultProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);

      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final success = await ProfileService.updateProfile(updatedUser);

      if (!mounted) return;
      setState(() => _isSaving = false);

      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Profil berhasil diperbarui!',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
        nav.pop(updatedUser);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui profil. Periksa koneksi Anda.',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BookstoreAppBar(
        title: 'Edit Profil',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Avatar Editor
                      EditProfileAvatar(
                        imagePath: widget.user.avatarUrl,
                        onChangePhoto: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Fitur upload foto profil segera hadir!',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Nama Lengkap
                      EditProfileField(
                        label: 'Nama Lengkap',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        hintText: 'Masukkan nama lengkap',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Email
                      EditProfileField(
                        label: 'Alamat Email',
                        controller: _emailController,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'nama@email.com',
                        readOnly: true,
                        labelTrailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successContainer,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Terverifikasi',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Nomor HP
                      EditProfileField(
                        label: 'Nomor Handphone',
                        controller: _phoneController,
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        hintText: '+62 812-xxxx-xxxx',
                        helperText:
                            'Digunakan untuk koordinasi konfirmasi kurir saat pengiriman pesanan.',
                        helperIcon: Icons.info_outline_rounded,
                        helperIconColor: AppColors.secondary,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor handphone tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Security Info Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Data profil Anda dilindungi dan disimpan aman di server Buka Buku untuk keperluan transaksi & pengiriman.',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(
                  top: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: AppTypography.titleMd.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
