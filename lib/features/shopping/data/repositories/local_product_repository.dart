// lib/features/shopping/data/repositories/local_product_repository.dart
/// Local Product Repository - In-Memory Storage for Shopping Items
/// 
/// Implements the [ProductRepository] interface to provide a static list of 
/// healthy lifestyle products that can be purchased using XP (experience points)
/// earned from completing quests. Serves as a simple, local data source for 
/// the shopping feature, with no persistent storage.
library;
import 'package:solo_leveling/features/shopping/data/models/product_model.dart';
import 'package:solo_leveling/features/shopping/data/repositories/product_repository.dart';

/// Local in-memory implementation of [ProductRepository]
/// 
/// Stores a predefined list of [Product] items focused on health, wellness, 
/// fitness, and personal growth. All products are always available (no stock 
/// management) and returned as-is when requested.
class LocalProductRepository implements ProductRepository {
  /// Predefined list of all available products
  /// 
  /// Each product includes an ID, name, and XP cost. Products are categorized 
  /// implicitly by their purpose (e.g., fitness equipment, wellness tools, 
  /// nutrition aids).
  final List<Product> _allProducts = [
    // Fitness Equipment
    const Product(id: 'yoga-mat', name: 'Yoga mat', xpCost: 200),
    const Product(id: 'resistance-bands', name: 'Resistance bands set', xpCost: 150),
    const Product(id: 'adjustable-dumbbells', name: 'Adjustable dumbbells', xpCost: 800),
    const Product(id: 'jump-rope', name: 'Weighted jump rope', xpCost: 100),
    const Product(id: 'massage-gun', name: 'Percussion massage gun', xpCost: 450),
    
    // Wellness & Recovery
    const Product(id: 'sleep-mask', name: '3D contoured sleep mask', xpCost: 75),
    const Product(id: 'essential-oils', name: 'Stress-relief essential oils kit', xpCost: 220),
    const Product(id: 'foam-roller', name: 'High-density foam roller', xpCost: 180),
    const Product(id: 'meditation-app-subscription', name: 'Meditation app premium subscription', xpCost: 180),
    
    // Nutrition & Hydration
    const Product(id: 'smart-water-bottle', name: 'Smart water bottle (hydration tracker)', xpCost: 300),
    const Product(id: 'protein-shaker', name: 'Leakproof protein shaker', xpCost: 90),
    const Product(id: 'meal-prep-containers', name: 'BPA-free meal prep containers (5-pack)', xpCost: 120),
    const Product(id: 'fruit-infuser', name: 'Fruit water infuser pitcher', xpCost: 150),
    
    // Mental Health & Productivity
    const Product(id: 'journal-pen-set', name: 'Gratitude journal & pen set', xpCost: 120),
    const Product(id: 'noise-canceling-headphones', name: 'Wireless noise-canceling headphones', xpCost: 500),
    const Product(id: 'mindfulness-cards', name: 'Mindfulness prompt cards', xpCost: 80),
    const Product(id: 'digital-detox-kit', name: 'Digital detox kit (screen-time tracker + activities)', xpCost: 200),
    
    // Active Lifestyle
    const Product(id: 'hiking-backpack', name: 'Lightweight hiking backpack', xpCost: 350),
    const Product(id: 'running-shoes', name: 'Cushioned running shoes', xpCost: 600),
    const Product(id: 'fitness-tracker', name: 'Basic fitness tracker (steps + heart rate)', xpCost: 250),
    const Product(id: 'outdoor-yoga-set', name: 'Portable outdoor yoga set (mat + strap)', xpCost: 280),
    
    // Social & Recreational Health
    const Product(id: 'coffee-shop-voucher', name: 'Organic coffee shop voucher', xpCost: 100),
    const Product(id: 'board-game-night-kit', name: 'Board game night kit (3 games)', xpCost: 250),
    const Product(id: 'hiking-guidebook', name: 'Local hiking trails guidebook', xpCost: 60),
    const Product(id: 'cooking-class-voucher', name: 'Healthy cooking class voucher', xpCost: 320),
    
    // Personal Growth
    const Product(id: 'online-course-voucher', name: 'Personal development online course voucher', xpCost: 350),
    const Product(id: 'habit-tracker', name: '3-month habit tracker planner', xpCost: 95),
    const Product(id: 'language-learning-sub', name: '1-month language learning subscription', xpCost: 170),
  ];

  /// Retrieves all available products
  /// 
  /// Returns the full list of predefined products, as there is no stock management
  /// or availability restrictions in this local implementation.
  /// 
  /// Future extensions:
  /// - Add stock quantities and availability checks
  /// - Implement product categorization/filtering
  /// - Add dynamic pricing based on user level or quest streaks
  @override
  Future<List<Product>> getAvailableProducts() async {
    return _allProducts;
  }
}