import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bookstore_app_bar.dart';
import '../models/shipping_address.dart';
import '../widgets/address_card.dart';
import '../widgets/address_delivery_banner.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  late List<ShippingAddress> _addresses;

  @override
  void initState() {
    super.initState();
    _addresses = List.from(ShippingAddress.defaultAddresses);
  }

  void _setAsPrimary(String id) {
    setState(() {
      _addresses = _addresses.map((addr) {
        return addr.copyWith(isPrimary: addr.id == id);
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Alamat utama berhasil diubah!',
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
  }

  void _deleteAddress(String id) {
    final addrToDelete = _addresses.firstWhere((a) => a.id == id);
    if (_addresses.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal harus ada 1 alamat pengiriman tersimpan.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Alamat?',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus alamat "${addrToDelete.label} - ${addrToDelete.recipientName}"?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: AppTypography.titleMd.copyWith(
                fontSize: 14,
                color: AppColors.outline,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _addresses.removeWhere((a) => a.id == id);
                if (addrToDelete.isPrimary && _addresses.isNotEmpty) {
                  _addresses[0] = _addresses[0].copyWith(isPrimary: true);
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Alamat berhasil dihapus',
                    style: AppTypography.bodyMd.copyWith(color: Colors.white),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: AppTypography.titleMd.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddressForm([ShippingAddress? existingAddress]) {
    final isEditing = existingAddress != null;
    final nameCtrl = TextEditingController(
      text: existingAddress?.recipientName ?? 'Budi Santoso',
    );
    final phoneCtrl = TextEditingController(
      text: existingAddress?.phoneNumber ?? '+62 812-3456-7890',
    );
    final addressCtrl = TextEditingController(
      text: existingAddress?.fullAddress ?? '',
    );
    final noteCtrl = TextEditingController(
      text: existingAddress?.courierNote ?? '',
    );
    String selectedLabel = existingAddress?.label ?? 'Rumah';
    bool makePrimary = existingAddress?.isPrimary ?? (_addresses.isEmpty);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Sheet Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Ubah Alamat Pengiriman' : 'Tambah Alamat Baru',
                          style: AppTypography.titleMd.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Label choice chips
                    Text(
                      'Label Alamat',
                      style: AppTypography.titleMd.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Rumah', 'Kantor', 'Apartemen'].map((label) {
                        final isSelected = selectedLabel == label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: AppColors.primaryContainer,
                            backgroundColor: AppColors.surfaceContainerLow,
                            labelStyle: AppTypography.caption.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurface,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant.withValues(alpha: 0.6),
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => selectedLabel = label);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Recipient Name
                    _buildModalTextField(
                      controller: nameCtrl,
                      label: 'Nama Penerima',
                      hint: 'Contoh: Budi Santoso',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    _buildModalTextField(
                      controller: phoneCtrl,
                      label: 'Nomor Handphone',
                      hint: '+62 8xx-xxxx-xxxx',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Full Address
                    _buildModalTextField(
                      controller: addressCtrl,
                      label: 'Alamat Lengkap',
                      hint: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan, kota & kode pos',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Courier Note
                    _buildModalTextField(
                      controller: noteCtrl,
                      label: 'Catatan untuk Kurir (Opsional)',
                      hint: 'Warna pagar, patokan lokasi, titip satpam, dll.',
                      prefixIcon: Icons.note_alt_outlined,
                    ),
                    const SizedBox(height: 10),

                    // Primary Address Checkbox
                    CheckboxListTile(
                      value: makePrimary,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primaryContainer,
                      title: Text(
                        'Jadikan sebagai alamat utama',
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => makePrimary = val ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (addressCtrl.text.trim().isEmpty ||
                              nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Nama penerima dan alamat tidak boleh kosong',
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }

                          final newAddress = ShippingAddress(
                            id: isEditing
                                ? existingAddress.id
                                : 'addr_${DateTime.now().millisecondsSinceEpoch}',
                            recipientName: nameCtrl.text.trim(),
                            phoneNumber: phoneCtrl.text.trim(),
                            label: selectedLabel,
                            fullAddress: addressCtrl.text.trim(),
                            courierNote: noteCtrl.text.trim().isEmpty
                                ? null
                                : noteCtrl.text.trim(),
                            isPrimary: makePrimary,
                            isGeotagVerified: isEditing
                                ? existingAddress.isGeotagVerified
                                : true,
                          );

                          setState(() {
                            if (isEditing) {
                              final index = _addresses
                                  .indexWhere((a) => a.id == existingAddress.id);
                              if (index != -1) {
                                _addresses[index] = newAddress;
                              }
                            } else {
                              _addresses.add(newAddress);
                            }

                            if (makePrimary) {
                              _addresses = _addresses.map((a) {
                                return a.copyWith(isPrimary: a.id == newAddress.id);
                              }).toList();
                            }
                          });

                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Alamat berhasil diperbarui!'
                                    : 'Alamat baru berhasil ditambahkan!',
                                style: AppTypography.bodyMd
                                    .copyWith(color: Colors.white),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Simpan Perubahan' : 'Tambahkan Alamat',
                          style: AppTypography.titleMd.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMd.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTypography.bodyMd.copyWith(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.caption.copyWith(
              color: AppColors.outline,
              fontSize: 12.5,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppColors.outline)
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryContainer,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const BookstoreAppBar(
        title: 'Alamat Pengiriman',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BUKU & PENGIRIMAN',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Daftar Alamat Saya',
                            style: AppTypography.headlineMd.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pilih alamat utama atau kelola alamat tujuan pengantaran paket buku pesanan Anda.',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Address List
                    for (int i = 0; i < _addresses.length; i++) ...[
                      AddressCard(
                        address: _addresses[i],
                        onSetPrimary: () => _setAsPrimary(_addresses[i].id),
                        onEdit: () => _openAddressForm(_addresses[i]),
                        onDelete: () => _deleteAddress(_addresses[i].id),
                      ),
                      const SizedBox(height: 14),
                    ],

                    const SizedBox(height: 8),

                    // Delivery Guarantee Banner
                    const AddressDeliveryBanner(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Add Button
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
                child: ElevatedButton.icon(
                  onPressed: () => _openAddressForm(),
                  icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                  label: Text(
                    'Tambah Alamat Baru',
                    style: AppTypography.titleMd.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
