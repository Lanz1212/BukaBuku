/// Simulation flows matching Stitch screen ecf4c766eb544d318976098afeb67cee
enum OrderSimulationFlow {
  delivery,
  pickupOnline,
  pickupCash;

  String get tabLabel {
    switch (this) {
      case OrderSimulationFlow.delivery:
        return '1. Antar Rumah';
      case OrderSimulationFlow.pickupOnline:
        return '2. Ambil Online';
      case OrderSimulationFlow.pickupCash:
        return '3. Bayar Kasir';
    }
  }

  int get totalAmount {
    switch (this) {
      case OrderSimulationFlow.delivery:
        return 181000;
      case OrderSimulationFlow.pickupOnline:
      case OrderSimulationFlow.pickupCash:
        return 169000;
    }
  }

  bool get hasDeliveryFee => this == OrderSimulationFlow.delivery;

  int get deliveryFee => hasDeliveryFee ? 12000 : 0;

  String get step3Title {
    switch (this) {
      case OrderSimulationFlow.delivery:
        return '3. Siap Dikirim Kurir';
      case OrderSimulationFlow.pickupOnline:
      case OrderSimulationFlow.pickupCash:
        return '3. Siap Diambil di Rak Toko';
    }
  }

  String get step3Description {
    switch (this) {
      case OrderSimulationFlow.delivery:
        return 'Paket diserahkan ke kurir untuk perjalanan menuju lokasimu.';
      case OrderSimulationFlow.pickupOnline:
      case OrderSimulationFlow.pickupCash:
        return 'Buku siap diambil langsung di meja kurasi Toko Buku Budi Cikini.';
    }
  }
}
