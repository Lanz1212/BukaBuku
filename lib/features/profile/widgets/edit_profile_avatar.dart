import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../services/profile_service.dart';

class EditProfileAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String? userName;
  final ValueChanged<String>? onAvatarChanged;
  final VoidCallback? onAvatarRemoved;

  const EditProfileAvatar({
    super.key,
    this.avatarUrl,
    this.userName,
    this.onAvatarChanged,
    this.onAvatarRemoved,
  });

  @override
  State<EditProfileAvatar> createState() => _EditProfileAvatarState();
}

class _EditProfileAvatarState extends State<EditProfileAvatar> {
  bool _isUploading = false;
  String? _currentAvatarUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _currentAvatarUrl = widget.avatarUrl;
  }

  @override
  void didUpdateWidget(covariant EditProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.avatarUrl != oldWidget.avatarUrl) {
      _currentAvatarUrl = widget.avatarUrl;
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null || !mounted) return;

      setState(() => _isUploading = true);

      final bytes = await picked.readAsBytes();
      final extension = picked.name.split('.').last;

      final newUrl = await ProfileService.uploadAvatar(
        bytes: bytes,
        fileExtension: extension,
      );

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        if (newUrl != null) {
          _currentAvatarUrl = newUrl;
        }
      });

      final messenger = ScaffoldMessenger.of(context);
      if (newUrl != null) {
        widget.onAvatarChanged?.call(newUrl);
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Foto profil berhasil diperbarui!',
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
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunggah foto profil. Silakan coba lagi.',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan saat memilih foto: $e',
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

  Future<void> _handleRemoveAvatar() async {
    setState(() => _isUploading = true);
    final success = await ProfileService.removeAvatar();
    if (!mounted) return;

    setState(() {
      _isUploading = false;
      if (success) {
        _currentAvatarUrl = null;
      }
    });

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      widget.onAvatarRemoved?.call();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Foto profil berhasil dihapus.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus foto profil.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showImageSourcePicker() {
    if (_isUploading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Sumber Foto Profil',
                style: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih foto dari penyimpanan perangkat Anda',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primaryContainer,
                  ),
                ),
                title: Text(
                  'Galeri Foto / Storage HP',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Pilih berkas foto dari penyimpanan HP',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text(
                  'Kamera HP',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Ambil foto baru langsung dari kamera',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) ...[
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                  ),
                  title: Text(
                    'Hapus Foto Profil',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  subtitle: Text(
                    'Kembali menggunakan avatar default',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleRemoveAvatar();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_isUploading) {
      return Container(
        color: AppColors.surfaceContainerLow,
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryContainer,
            ),
          ),
        ),
      );
    }

    final hasNetworkUrl = _currentAvatarUrl != null &&
        _currentAvatarUrl!.trim().isNotEmpty &&
        _currentAvatarUrl!.startsWith('http');

    if (hasNetworkUrl) {
      return Image.network(
        _currentAvatarUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.surfaceContainerLow,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryContainer,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final name = widget.userName?.trim() ?? '';
    if (name.isNotEmpty) {
      final initial = name.characters.first.toUpperCase();
      return Container(
        color: AppColors.primaryContainer,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTypography.headlineMd.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 36,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.primaryContainer,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 54,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondaryFixedDim,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildAvatarContent(),
                ),
              ),

              // Camera icon badge
              Positioned(
                bottom: 0,
                right: -2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isUploading ? null : _showImageSourcePicker,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isUploading
                            ? Icons.hourglass_top_rounded
                            : Icons.camera_alt_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourcePicker,
          child: Text(
            _isUploading ? 'Sedang Mengunggah Foto...' : 'Ubah Foto Profil',
            style: AppTypography.titleMd.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isUploading ? AppColors.outline : AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Format JPG, PNG atau WebP (maks 2MB)',
          style: AppTypography.caption.copyWith(
            color: AppColors.outline,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
