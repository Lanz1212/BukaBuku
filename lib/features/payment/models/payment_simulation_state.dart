import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Enum representing the 4 states supported in the QRIS payment simulation
/// as specified in Google Stitch project Toko Buku Budi Mobile UI.
enum PaymentSimulationStatus {
  pending,
  success,
  failed,
  expired,
}

extension PaymentSimulationStatusExtension on PaymentSimulationStatus {
  String get tabLabel {
    switch (this) {
      case PaymentSimulationStatus.pending:
        return '1. Menunggu';
      case PaymentSimulationStatus.success:
        return '2. Berhasil';
      case PaymentSimulationStatus.failed:
        return '3. Gagal';
      case PaymentSimulationStatus.expired:
        return '4. Kedaluwarsa';
    }
  }

  String get title {
    switch (this) {
      case PaymentSimulationStatus.pending:
        return 'Selesaikan Pembayaran';
      case PaymentSimulationStatus.success:
        return 'Pembayaran Berhasil!';
      case PaymentSimulationStatus.failed:
        return 'Pembayaran Gagal';
      case PaymentSimulationStatus.expired:
        return 'Kode QR Kedaluwarsa';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentSimulationStatus.pending:
        return Icons.timer_outlined;
      case PaymentSimulationStatus.success:
        return Icons.check_circle_outline;
      case PaymentSimulationStatus.failed:
        return Icons.error_outline;
      case PaymentSimulationStatus.expired:
        return Icons.hourglass_disabled_outlined;
    }
  }

  Color get statusColor {
    switch (this) {
      case PaymentSimulationStatus.pending:
        return AppColors.secondary;
      case PaymentSimulationStatus.success:
        return const Color(0xFF3F8F5F); // DESIGN.md success laurel green
      case PaymentSimulationStatus.failed:
        return AppColors.error;
      case PaymentSimulationStatus.expired:
        return AppColors.outline;
    }
  }
}
