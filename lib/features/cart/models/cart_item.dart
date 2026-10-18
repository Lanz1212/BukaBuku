/// Model representing an item in the shopping cart for Toko Buku Budi
class CartItem {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final String formatEdition;
  final String price;
  final int priceValue;
  final String? originalPrice;
  final int? originalPriceValue;
  final String coverUrl;
  final String storeLocation;
  final int quantity;
  final bool isSelected;

  const CartItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.formatEdition,
    required this.price,
    required this.priceValue,
    this.originalPrice,
    this.originalPriceValue,
    required this.coverUrl,
    this.storeLocation = 'Tersedia di Toko Cikini',
    this.quantity = 1,
    this.isSelected = true,
  });

  CartItem copyWith({
    String? id,
    String? bookId,
    String? title,
    String? author,
    String? formatEdition,
    String? price,
    int? priceValue,
    String? originalPrice,
    int? originalPriceValue,
    String? coverUrl,
    String? storeLocation,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      formatEdition: formatEdition ?? this.formatEdition,
      price: price ?? this.price,
      priceValue: priceValue ?? this.priceValue,
      originalPrice: originalPrice ?? this.originalPrice,
      originalPriceValue: originalPriceValue ?? this.originalPriceValue,
      coverUrl: coverUrl ?? this.coverUrl,
      storeLocation: storeLocation ?? this.storeLocation,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Default dataset matching the Stitch reference design
  static const List<CartItem> defaultCartItems = [
    CartItem(
      id: 'cart-1',
      bookId: 'atomic-habits-new',
      title: 'Atomic Habits',
      author: 'James Clear',
      formatEdition: '1x Paperback (Hard cover foil)',
      price: 'Rp85.000',
      priceValue: 85000,
      originalPrice: 'Rp105.000',
      originalPriceValue: 105000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC52cLVUTruCewsPuyF1ftioLURCqsC3blVAKunpM8-XSQ3slS93vof9l5w0ZAZg8Cy7FPe_08L9lP1QOAYnkUwGCgsbLiOVEG_WFE2HTIZpXtYN7quhNIqu2rQfNCFu2YD0Brzcts3GXMkpmJiE3hzEihUtqsVH50LmjRG-Tt7FPr9cH-ogi4unalFcrZXExqG_BqOJCRSRM9qMSc82IhSc8NvNlFKhD6jU6ou28aGWGP9XyYwRr96Hg',
      storeLocation: 'Tersedia di Toko Cikini',
      quantity: 1,
      isSelected: true,
    ),
    CartItem(
      id: 'cart-2',
      bookId: 'filosofi-teras',
      title: 'Filosofi Teras (Edisi Baru)',
      author: 'Henry Manampiring',
      formatEdition: '1x Edisi Sampul Khusus Cikini',
      price: 'Rp98.000',
      priceValue: 98000,
      coverUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBzTVE89jrEffqqIm843A2EJ34oRRJqAgrI-pAH-34Ic5NSZmKAXBfI_bEVBLJ-FeLmG3F-Q8p_4Acfma-nEYx0o3WnJTrEFnjv5GOK6pAphzSWoX9VxeNqLT5ggvaCy6ScgKT88_sbKyTYCzSCwNCMyi8bp9-eCWIMgK8XH33_AMTYaGTbPR7laTNHkc-6PXJaP3R3gujt3UgmR_mh-6CwysRWPVgm1Pw7_Z-ilD3XkW1lvqa_xzB-0Q',
      storeLocation: 'Tersedia di Toko Cikini',
      quantity: 1,
      isSelected: true,
    ),
  ];
}
