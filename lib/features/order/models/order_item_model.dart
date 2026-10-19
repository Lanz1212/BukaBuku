class OrderItemModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String? tag;
  final int quantity;
  final String pricePerUnit;
  final int pricePerUnitValue;
  final String subtotal;
  final int subtotalValue;

  const OrderItemModel({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.tag,
    required this.quantity,
    required this.pricePerUnit,
    required this.pricePerUnitValue,
    required this.subtotal,
    required this.subtotalValue,
  });
}
