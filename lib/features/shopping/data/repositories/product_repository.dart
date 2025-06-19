import 'package:solo_leveling/features/shopping/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getAvailableProducts();
}