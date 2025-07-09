import 'package:duolympix/features/shopping/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> getAvailableProducts();
}