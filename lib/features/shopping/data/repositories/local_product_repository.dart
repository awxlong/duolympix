// lib/features/shopping/data/repositories/local_product_repository.dart
import 'package:solo_leveling/features/shopping/data/models/product_model.dart';
import 'package:solo_leveling/features/shopping/data/repositories/product_repository.dart';

class LocalProductRepository implements ProductRepository {
  final List<Product> _allProducts = [
    const Product(id: 'yoga-mat', name: 'Yoga mat', xpCost: 200),
    const Product(id: 'smart-water-bottle', name: 'Smart water bottle', xpCost: 3000),
    const Product(id: 'meditation-app-subscription', name: 'Meditation app premium subscription', xpCost: 180),
    const Product(id: 'journal-pen-set', name: 'Journal & pen set', xpCost: 120),
    const Product(id: 'online-course-voucher', name: 'Custom Online course voucher', xpCost: 3500),
    const Product(id: 'massage-gun', name: 'Massage gun', xpCost: 450),
    const Product(id: 'coffee-shop-voucher', name: 'Coffee shop voucher', xpCost: 1000),
    const Product(id: 'board-game-night-kit', name: 'Board game night kit', xpCost: 2500),
  ];

  @override
  Future<List<Product>> getAvailableProducts() async {
    return _allProducts;
  }
}
