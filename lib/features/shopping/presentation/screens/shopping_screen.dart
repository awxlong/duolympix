// lib/features/shopping/presentation/screens/shopping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/features/shopping/data/models/product_model.dart';
import 'package:solo_leveling/features/shopping/data/repositories/local_product_repository.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Your XP: ${user?.totalXp}', style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Cost: ${product.xpCost} XP'),
                        trailing: ElevatedButton(
                          onPressed: user!.totalXp >= product.xpCost
                              ? () async {
                                  final updatedUser = user.purchaseProduct(product);
                                  await userProvider.updateUser(updatedUser);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product purchased successfully!')),
                                  );
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