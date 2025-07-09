// lib/features/shopping/presentation/screens/shopping_screen.dart
/// Shopping Screen
/// 
/// Allows users to browse and purchase products using XP (experience points)
/// earned from completing quests. Displays available products, their XP costs,
/// and handles the purchase process with validation for sufficient XP.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duolympix/features/profile/data/providers/user_provider.dart';
import 'package:duolympix/features/shopping/data/models/product_model.dart';
import 'package:duolympix/features/shopping/data/repositories/local_product_repository.dart';

/// Screen for browsing and purchasing products with XP
/// 
/// Shows the user's current XP balance and a list of available products.
/// Each product displays its name, XP cost, and a purchase button (enabled
/// only if the user has enough XP). Handles purchase transactions and
/// updates user data accordingly.
class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  /// Future for loading available products from the repository
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize product repository and load products
    final productRepository = LocalProductRepository();
    _productsFuture = productRepository.getAvailableProducts();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display user's current XP balance
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Your XP: ${user?.totalXp}', style: const TextStyle(fontSize: 18)),
          ),
          // Product list
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Error state
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Success state with product list
                else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Cost: ${product.xpCost} XP'),
                        trailing: ElevatedButton(
                          // Purchase button enabled only if user has enough XP
                          onPressed: user!.totalXp >= product.xpCost
                              ? () async {
                                  // Store scaffold messenger before async operation
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                  // Process purchase and update user data
                                  final updatedUser = user.purchaseProduct(product);
                                  await userProvider.updateUser(updatedUser);
                                  // Show success message if widget is still mounted
                                  if (mounted) {
                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(content: Text('Product purchased successfully!')),
                                    );
                                  }
                                }
                              : null,
                          child: const Text('Buy'),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
