// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Get UserProvider from context
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      // Get user email from auth or local storage
      const email = 'ucabxan@ucl.ac.uk'; // Replace with actual auth logic
      
      // Now safe to use userProvider
      await userProvider.loadUser(email);
      
      // Navigate to quest list after loading user data
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/quests');
      }
    } catch (e) {
      if (mounted) {
        // Handle errors, e.g., show login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Solo Leveling',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
