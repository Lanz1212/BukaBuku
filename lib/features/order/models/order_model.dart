import 'order_item_model.dart';

enum OrderStatus {
  all,
  processing,
  shipping,
  readyPickup,
  completed,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.all:
        return 'Semua';
      case OrderStatus.processing:
        return 'Diproses';
      case OrderStatus.shipping:
        return 'Dikirim';
      case OrderStatus.readyPickup:
        return 'Siap Diambil';
      case OrderStatus.completed:
        return 'Selesai';
    }
  }
}

enum DeliveryType {
  pickup,
  delivery,
}

class OrderTimelineStepModel {
  final String title;
  final String time;
  final String description;
  final bool isDone;
  final bool isActive;

  const OrderTimelineStepModel({
    required this.title,
    required this.time,
    required this.description,
    this.isDone = false,
    this.isActive = false,
  });
}

class OrderModel {
  final String id;
  final String dateTimeStr;
  final String orderDateExact;
  final OrderStatus status;
  final bool isPaid;
  final DeliveryType deliveryType;
  final String deliveryBadgeLabel;
  final String? packageNote;
  final String? pickupLocation;
  final String? pickupSchedule;
  final String? branchName;
  final String? branchAddress;
  final String? branchSchedule;
  final String? courierName;
  final String? courierEta;
  final String? trackingNumber;
  final String? completionNote;
  final String? completionDate;
  final String summaryTitle;
  final String summarySubtitle;
  final String summaryItemCountLabel;
  final String summaryCoverUrl;
  final List<OrderItemModel> items;
  final String subtotal;
  final int subtotalValue;
  final String? voucherCode;
  final String? voucherDiscount;
  final int? voucherDiscountValue;
  final String shippingCost;
  final String serviceFee;
  final int serviceFeeValue;
  final String totalAmount;
  final int totalAmountValue;
  final String paymentMethod;
  final String customerName;
  final String qrCode;
  final String qrCodeDetail;
  final String validUntil;
  final List<OrderTimelineStepModel> timeline;

  const OrderModel({
    required this.id,
    required this.dateTimeStr,
    required this.orderDateExact,
    required this.status,
    this.isPaid = true,
    required this.deliveryType,
    required this.deliveryBadgeLabel,
    this.packageNote,
    this.pickupLocation,
    this.pickupSchedule,
    this.branchName,
    this.branchAddress,
    this.branchSchedule,
    this.courierName,
    this.courierEta,
    this.trackingNumber,
    this.completionNote,
    this.completionDate,
    required this.summaryTitle,
    required this.summarySubtitle,
    required this.summaryItemCountLabel,
    required this.summaryCoverUrl,
    required this.items,
    required this.subtotal,
    required this.subtotalValue,
    this.voucherCode,
    this.voucherDiscount,
    this.voucherDiscountValue,
    this.shippingCost = 'Gratis',
    this.serviceFee = 'Rp1.000',
    this.serviceFeeValue = 1000,
    required this.totalAmount,
    required this.totalAmountValue,
    this.paymentMethod = 'QRIS BCA',
    this.customerName = 'Budi Darmawan',
    this.qrCode = 'PKP-880-CJK',
    this.qrCodeDetail = 'ORD-00125-CKN',
    this.validUntil = '19 Mei 2024, 21:00 WIB',
    this.timeline = const [],
  });
}

/// Sample Dataset matching Toko Buku Budi Stitch specification
final List<OrderModel> mockOrders = [
  OrderModel(
    id: '#ORD00125',
    dateTimeStr: '12 Mei 2024 • 14:30 WIB',
    orderDateExact: '12 Mei 2024, 14:32 WIB',
    status: OrderStatus.readyPickup,
    isPaid: true,
    deliveryType: DeliveryType.pickup,
    deliveryBadgeLabel: 'Ambil di Toko Cabang',
    packageNote: 'Buku Telah Dibungkus Rapih',
    pickupLocation: 'Meja Kasir 1 • Toko Buku Budi Cabang Cikini, Jakarta Pusat',
    pickupSchedule: 'Buka sampai 21.00 WIB hari ini',
    branchName: 'Toko Buku Budi Cikini',
    branchAddress: 'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat 10330',
    branchSchedule: 'Buka Hari Ini: 08.00 – 21.00 WIB',
    summaryTitle: 'Laut Bercerita & 1 Buku Lainnya',
    summarySubtitle: 'Leila S. Chudori, dkk • Hardcover & Softcover',
    summaryItemCountLabel: '2 Buku Bacaan',
    summaryCoverUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAxocHTxqliESnFIap-gx_xI4ALydqM-Kzd_TsWjqxF1vqPYVayZYzxnIJ36S9sb1faxsb3-Vav1VGU7Nbo2ry06MdDSq1x3A2sXkbO8fRSwvxSapOKqJGw8oTi_ZoCjSItbgPQMLRwrD3xSCsZjCfqd8KxA2ydDjbGSNIenXArdNVYRtjtehga__kSYlFSEfMQAhsMObUylznu3fyhgbmyy2_mtlYNq-esx6klP9xaiAlLaONRfa-VaQ',
    items: const [
      OrderItemModel(
        id: 'item-atomic-habits',
        title: 'Atomic Habits',
        author: 'James Clear',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDFiKMYP0hPLV6ZpU4Qv_Wsv69nyK7ht4_RnnxRjXnG6hzP6YIKCnbirCPxX8KzwLuZWL3RStABW_QFnbrwHKJD6bK6c2k3PbgPQ7vVSbBR4HX95Un5X8oRaB5vORJQsMi8cKbj71lwRYm2CiKVvg1sTUM2ch67GEWCrDkYpj9O-weNugHcA8IAta4LPzORfts-RZgxtpSQPm4Ge1xVK4l17ia2o8wrYwGyqywBbt-BEg9TloZQ9FqG2A',
        tag: 'Paperback • Bahasa Indonesia',
        quantity: 1,
        pricePerUnit: 'Rp85.000',
        pricePerUnitValue: 85000,
        subtotal: 'Rp85.000',
        subtotalValue: 85000,
      ),
      OrderItemModel(
        id: 'item-filosofi-teras',
        title: 'Filosofi Teras',
        author: 'Henry Manampiring',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBt1ink9dGVvSrg2Ti624nm0BKr_mSLKBAlR5lqCW9g-QOFu7RlWL23h6uwVgZonxKPVoyUqAEmqUUowpmM7xr2EPgXCkgjTT3cP-j8gmm9oUll6-2mwKm7YDFsg9dUG1-i6AAlHa7WOSYgEvP9DPVbRWkcJDESuexqjaIctrIbbZ_36INoH0SwncDSAYHyYvXh0ZK1hIAWPnW5SOdiaq3llkLklRPaFZ3yAB9ktHyYOauPmecNQXySXQ',
        tag: 'Edisi Sampul Khusus Hardcover',
        quantity: 1,
        pricePerUnit: 'Rp98.000',
        pricePerUnitValue: 98000,
        subtotal: 'Rp98.000',
        subtotalValue: 98000,
      ),
    ],
    subtotal: 'Rp183.000',
    subtotalValue: 183000,
    voucherCode: 'BUDISANTAI',
    voucherDiscount: '-Rp15.000',
    voucherDiscountValue: -15000,
    shippingCost: 'Gratis',
    serviceFee: 'Rp1.000',
    serviceFeeValue: 1000,
    totalAmount: 'Rp181.000',
    totalAmountValue: 181000,
    paymentMethod: 'QRIS BCA',
    customerName: 'Budi Darmawan',
    qrCode: 'PKP-880-CJK',
    qrCodeDetail: 'ORD-00125-CKN',
    validUntil: '19 Mei 2024, 21:00 WIB',
    timeline: const [
      OrderTimelineStepModel(
        title: 'Pesanan Dibuat',
        time: '14:30 WIB',
        description: 'Pesanan berhasil tercatat di sistem Toko Buku Budi.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Pembayaran Lunas',
        time: '14:32 WIB',
        description: 'Terverifikasi otomatis melalui QRIS.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Diproses Kurator Buku',
        time: '15:00 WIB',
        description:
            'Dibungkus rapi dengan kertas kraft ramah lingkungan & pembatas buku khas Cikini.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Siap Diambil di Toko',
        time: '16:15 WIB',
        description:
            'Tersedia di meja kasir Toko Cikini dengan nomor referensi #ORD00125.',
        isActive: true,
      ),
      OrderTimelineStepModel(
        title: 'Selesai',
        time: '',
        description: 'Menunggu konfirmasi pengambilan buku oleh pembaca.',
      ),
    ],
  ),
  OrderModel(
    id: '#ORD00118',
    dateTimeStr: '11 Mei 2024 • 09:15 WIB',
    orderDateExact: '11 Mei 2024, 09:15 WIB',
    status: OrderStatus.shipping,
    isPaid: true,
    deliveryType: DeliveryType.delivery,
    deliveryBadgeLabel: 'Sedang Dikirim',
    courierName: 'Kurir Buku Budi Express',
    courierEta: 'Tiba Sore Ini',
    trackingNumber: 'BKD-882194',
    summaryTitle: 'Cantik Itu Luka (Edisi Khusus)',
    summarySubtitle: 'Eka Kurniawan • Segel Original',
    summaryItemCountLabel: '1 Buku',
    summaryCoverUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDnpHkS5HNtiZoOu97zO3Zo1SFf42_BWxPKv7_v5E15oydmrWAnAqpgi6tRnrNMqweyVhDAGCSkl63Bv07xkQOMyrDRT9sz35qlSp7hX3K7_xHHQpuzZeoEjqw7vCVLmIeSu6dkthQYlminKfJJ74iBn4TmqUF2OnMwbgD1iMZ55gtxhF1KG-gjtYyDznF4dbwgVy_dbUD2akbE2SecKNwHVdK2T7XZ3hc-PI7MZXwcmqjyiNUhzn58CQ',
    items: const [
      OrderItemModel(
        id: 'item-cantik-itu-luka',
        title: 'Cantik Itu Luka (Edisi Khusus)',
        author: 'Eka Kurniawan',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDnpHkS5HNtiZoOu97zO3Zo1SFf42_BWxPKv7_v5E15oydmrWAnAqpgi6tRnrNMqweyVhDAGCSkl63Bv07xkQOMyrDRT9sz35qlSp7hX3K7_xHHQpuzZeoEjqw7vCVLmIeSu6dkthQYlminKfJJ74iBn4TmqUF2OnMwbgD1iMZ55gtxhF1KG-gjtYyDznF4dbwgVy_dbUD2akbE2SecKNwHVdK2T7XZ3hc-PI7MZXwcmqjyiNUhzn58CQ',
        tag: 'Sastra Klasik',
        quantity: 1,
        pricePerUnit: 'Rp105.000',
        pricePerUnitValue: 105000,
        subtotal: 'Rp105.000',
        subtotalValue: 105000,
      ),
    ],
    subtotal: 'Rp105.000',
    subtotalValue: 105000,
    shippingCost: 'Gratis',
    serviceFee: 'Rp1.000',
    serviceFeeValue: 1000,
    totalAmount: 'Rp105.000',
    totalAmountValue: 105000,
    paymentMethod: 'Transfer Bank Mandiri',
    customerName: 'Budi Darmawan',
    qrCode: 'PKP-880-DLV',
    qrCodeDetail: 'ORD-00118-DLV',
    validUntil: '18 Mei 2024, 21:00 WIB',
    timeline: const [
      OrderTimelineStepModel(
        title: 'Pesanan Dibuat',
        time: '09:15 WIB',
        description: 'Pesanan berhasil tercatat di sistem Toko Buku Budi.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Pembayaran Lunas',
        time: '09:20 WIB',
        description: 'Terverifikasi otomatis.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Sedang Dikirim',
        time: '13:00 WIB',
        description: 'Dibawa oleh Kurir Buku Budi Express menuju alamat Anda.',
        isActive: true,
      ),
      OrderTimelineStepModel(
        title: 'Pesanan Diterima',
        time: '',
        description: 'Menunggu konfirmasi penerimaan paket.',
      ),
    ],
  ),
  OrderModel(
    id: '#ORD00094',
    dateTimeStr: '28 April 2024 • 11:20 WIB',
    orderDateExact: '28 April 2024, 11:20 WIB',
    status: OrderStatus.completed,
    isPaid: true,
    deliveryType: DeliveryType.pickup,
    deliveryBadgeLabel: 'Ambil di Toko',
    completionNote: 'Buku telah diterima di Toko Buku Budi Cikini',
    completionDate: '28 Apr',
    summaryTitle: 'Nusantara: Sejarah Silang Budaya',
    summarySubtitle: 'Bernard H.M. Vlekke • Jilid 1',
    summaryItemCountLabel: '1 Buku',
    summaryCoverUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD8fjk_Z9rbUhOZyCLdKtrqA21HS0cmgpNdfuM2muW8Oeogi6z2-dVhNGvTnqMf9GB4JTrd0JahINf_LT10IUK6V6BLMS-G8Xab2c3MPenUOwLnbmP2_HH2G-pYffrXhFw7agy2aHnzdvp7uHKQK-B_cUZjqKq7rXcUmhaAPb9csRgieof54cDHgpCtupduVX2sUYd9VYBik-sDGJl9L8LdhfMVui3L1lJ3NH4zDXMPdeIoCeOEaby0lg',
    items: const [
      OrderItemModel(
        id: 'item-sejarah-nusantara',
        title: 'Nusantara: Sejarah Silang Budaya',
        author: 'Bernard H.M. Vlekke',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD8fjk_Z9rbUhOZyCLdKtrqA21HS0cmgpNdfuM2muW8Oeogi6z2-dVhNGvTnqMf9GB4JTrd0JahINf_LT10IUK6V6BLMS-G8Xab2c3MPenUOwLnbmP2_HH2G-pYffrXhFw7agy2aHnzdvp7uHKQK-B_cUZjqKq7rXcUmhaAPb9csRgieof54cDHgpCtupduVX2sUYd9VYBik-sDGJl9L8LdhfMVui3L1lJ3NH4zDXMPdeIoCeOEaby0lg',
        tag: 'Sejarah & Budaya',
        quantity: 1,
        pricePerUnit: 'Rp125.000',
        pricePerUnitValue: 125000,
        subtotal: 'Rp125.000',
        subtotalValue: 125000,
      ),
    ],
    subtotal: 'Rp125.000',
    subtotalValue: 125000,
    shippingCost: 'Gratis',
    serviceFee: 'Rp1.000',
    serviceFeeValue: 1000,
    totalAmount: 'Rp125.000',
    totalAmountValue: 125000,
    paymentMethod: 'QRIS BCA',
    customerName: 'Budi Darmawan',
    qrCode: 'PKP-094-SLS',
    qrCodeDetail: 'ORD-00094-SLS',
    validUntil: 'Selesai',
    timeline: const [
      OrderTimelineStepModel(
        title: 'Pesanan Dibuat',
        time: '11:20 WIB',
        description: 'Pesanan berhasil tercatat.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Pembayaran Lunas',
        time: '11:22 WIB',
        description: 'Terverifikasi otomatis via QRIS.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Siap Diambil',
        time: '14:00 WIB',
        description: 'Paket siap di cabang Cikini.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Pesanan Selesai',
        time: '16:30 WIB',
        description: 'Telah diserahkan kepada pembaca.',
        isDone: true,
      ),
    ],
  ),
  OrderModel(
    id: '#ORD00130',
    dateTimeStr: '19 Mei 2024 • 10:00 WIB',
    orderDateExact: '19 Mei 2024, 10:00 WIB',
    status: OrderStatus.processing,
    isPaid: true,
    deliveryType: DeliveryType.pickup,
    deliveryBadgeLabel: 'Ambil di Toko Cabang',
    packageNote: 'Sedang disiapkan kurator buku',
    pickupLocation: 'Meja Kasir 1 • Toko Buku Budi Cabang Cikini',
    pickupSchedule: 'Estimasi siap 2 jam lagi',
    branchName: 'Toko Buku Budi Cikini',
    branchAddress: 'Jl. Cikini Raya No. 42, Menteng, Jakarta Pusat 10330',
    branchSchedule: 'Buka Hari Ini: 08.00 – 21.00 WIB',
    summaryTitle: 'Sapiens: Riwayat Singkat Umat Manusia',
    summarySubtitle: 'Yuval Noah Harari • Softcover',
    summaryItemCountLabel: '1 Buku Bacaan',
    summaryCoverUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvfF1YQ9pMqv6jJ1tTf_X6c7g3Z1_O2vW3dM8g_N9tG4lPqV6sK3jR5bT7yU8iO9pL2kM1nB4vC6xZ8aD0sF2gH4jK6',
    items: const [
      OrderItemModel(
        id: 'item-sapiens',
        title: 'Sapiens: Riwayat Singkat Umat Manusia',
        author: 'Yuval Noah Harari',
        coverUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAvfF1YQ9pMqv6jJ1tTf_X6c7g3Z1_O2vW3dM8g_N9tG4lPqV6sK3jR5bT7yU8iO9pL2kM1nB4vC6xZ8aD0sF2gH4jK6',
        tag: 'Non-Fiksi Populer',
        quantity: 1,
        pricePerUnit: 'Rp135.000',
        pricePerUnitValue: 135000,
        subtotal: 'Rp135.000',
        subtotalValue: 135000,
      ),
    ],
    subtotal: 'Rp135.000',
    subtotalValue: 135000,
    shippingCost: 'Gratis',
    serviceFee: 'Rp1.000',
    serviceFeeValue: 1000,
    totalAmount: 'Rp136.000',
    totalAmountValue: 136000,
    paymentMethod: 'QRIS BCA',
    customerName: 'Budi Darmawan',
    qrCode: 'PKP-130-PRC',
    qrCodeDetail: 'ORD-00130-PRC',
    validUntil: '22 Mei 2024',
    timeline: const [
      OrderTimelineStepModel(
        title: 'Pesanan Dibuat',
        time: '10:00 WIB',
        description: 'Pesanan berhasil tercatat.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Pembayaran Lunas',
        time: '10:02 WIB',
        description: 'Terverifikasi otomatis.',
        isDone: true,
      ),
      OrderTimelineStepModel(
        title: 'Sedang Diproses Kurator',
        time: '10:15 WIB',
        description: 'Buku sedang diambil dari rak arsip.',
        isActive: true,
      ),
      OrderTimelineStepModel(
        title: 'Siap Diambil di Toko',
        time: '',
        description: 'Menunggu paket selesai dikemas.',
      ),
    ],
  ),
];
