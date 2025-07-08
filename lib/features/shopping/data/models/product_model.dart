// lib/features/shopping/data/models/product_model.dart
/// Entity representing a product in the shopping feature
class Product {
  final String id;
  final String name;
  final int xpCost;

  const Product({
    required this.id,
    required this.name,
    required this.xpCost,
  });
}
