import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../models/store_settings_model.dart';
import '../widgets/store_logo_card.dart';
import '../widgets/store_name_card.dart';
import '../widgets/store_location_card.dart';
import '../widgets/store_contact_card.dart';
import '../widgets/store_hours_card.dart';
import '../widgets/store_description_card.dart';
import '../widgets/store_pickup_policy_card.dart';
import '../widgets/store_gallery_card.dart';

/// Store Settings Screen for Store Admin (Pengaturan Toko)
/// Strictly conforms to DESIGN.md and Stitch Toko Buku Budi Mobile UI
class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  late StoreSettingsModel _settings;
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _settings = StoreSettingsModel.initialData;
    _nameController = TextEditingController(text: _settings.storeName);
    _addressController = TextEditingController(text: _settings.fullAddress);
    _phoneController = TextEditingController(text: _settings.phoneNumber);
    _whatsappController = TextEditingController(text: _settings.whatsappNumber);
    _descriptionController = TextEditingController(text: _settings.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showNotice(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              color: isSuccess ? AppColors.success : AppColors.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMd.copyWith(
                  color: isSuccess ? AppColors.onSurface : AppColors.onPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? AppColors.surfaceContainerLowest : AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSuccess
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        elevation: 6,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _settings = StoreSettingsModel.initialData;
      _nameController.text = _settings.storeName;
      _addressController.text = _settings.fullAddress;
      _phoneController.text = _settings.phoneNumber;
      _whatsappController.text = _settings.whatsappNumber;
      _descriptionController.text = _settings.description;
    });
    _showNotice('Pengaturan toko dikembalikan ke setelan awal', isSuccess: false);
  }

  void _saveChanges() {
    setState(() {
      _settings = _settings.copyWith(
        storeName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    });
    _showNotice('Perubahan profil gerai berhasil disimpan!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildCustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Banner / Intro Card
              _buildHeaderIntroCard(),
              const SizedBox(height: 14),

              // Logo & Visual Identity Card
              StoreLogoCard(
                onChangeLogo: () =>
                    _showNotice('Pilih file gambar logo baru (PNG/JPG)', isSuccess: false),
                onDeleteLogo: () =>
                    _showNotice('Logo gerai direset ke default', isSuccess: false),
              ),
              const SizedBox(height: 14),

              // Official Store Name Card
              StoreNameCard(
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              // Physical Store Address & Location Pinpoint Card
              StoreLocationCard(
                addressController: _addressController,
                coordinates: 'Cikini, Menteng (Lat: -6.1912, Long: 106.8404)',
                onPinpointMap: () =>
                    _showNotice('Buka peta koordinat lokasi Cikini', isSuccess: false),
              ),
              const SizedBox(height: 14),

              // Contact & Customer Service Card
              StoreContactCard(
                phoneController: _phoneController,
                whatsappController: _whatsappController,
              ),
              const SizedBox(height: 14),

              // Operating Hours Card
              StoreHoursCard(
                openTime: _settings.openTime,
                closeTime: _settings.closeTime,
                operatingDays: _settings.operatingDays,
                onSelectOpenTime: () => _pickTime(true),
                onSelectCloseTime: () => _pickTime(false),
              ),
              const SizedBox(height: 14),

              // Store Narrative Description Card
              StoreDescriptionCard(
                controller: _descriptionController,
              ),
              const SizedBox(height: 14),

              // Pickup Policy Card
              StorePickupPolicyCard(
                maxPickupHours: _settings.maxPickupHours,
              ),
              const SizedBox(height: 14),

              // Store Atmosphere Photo Card
              const StoreGalleryCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.96),
          border: Border(
            bottom: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  color: AppColors.onSurface,
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Kembali',
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/Logo Toko Buku Budi.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pengaturan Toko',
                    style: AppTypography.titleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded, size: 22),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () => _showNotice('Notifikasi toko aktif', isSuccess: false),
                  tooltip: 'Notifikasi',
                ),
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.onPrimary,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIntroCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 0.9,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.store_rounded,
                  size: 13,
                  color: AppColors.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'PROFIL GERAI FISIK',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengaturan Toko',
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola profil gerai fisik Toko Buku Budi Cikini, jam operasional, dan kontak resmi.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Reset / Refresh button
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 22,
                ),
                tooltip: 'Kembalikan Setelan Awal',
                onPressed: _resetToDefault,
              ),
            ),
            const SizedBox(width: 12),

            // Save Changes button
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 18,
                    color: AppColors.onPrimary,
                  ),
                  label: Text(
                    'Simpan Perubahan',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
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

  void _pickTime(bool isOpenTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime
          ? const TimeOfDay(hour: 8, minute: 0)
          : const TimeOfDay(hour: 21, minute: 0),
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      final formatted = '$hourStr:$minStr WIB';
      setState(() {
        if (isOpenTime) {
          _settings = _settings.copyWith(openTime: formatted);
        } else {
          _settings = _settings.copyWith(closeTime: formatted);
        }
      });
      _showNotice('Jam ${isOpenTime ? "Buka" : "Tutup"} diubah menjadi $formatted');
    }
  }
}
