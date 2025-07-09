// lib/features/auth/presentation/screens/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duolympix/features/profile/data/providers/user_provider.dart';
import 'package:duolympix/global_data/database/app_database.dart';
import 'package:duolympix/global_data/models/user.dart';
import 'package:duolympix/features/profile/data/mappers/user_mapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
  if (_formKey.currentState!.validate()) {
    final user = User(
      username: _usernameController.text,
      lastActive: DateTime.now(),
      password: _passwordController.text,
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userEntity = UserMapper.mapUserToEntity(user);

    // Check if the user already exists
    final database = await getDatabase();
    final existingUser = await database.userDao.findUserByUsername(user.username);
    if (existingUser == null) {
      // Insert the user into the database
      await database.userDao.insertUser(user);
    }

    await userProvider.loadUser(userEntity.username, userEntity.password);

    // After saving the user, navigate to the next screen (e.g., quest list)
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/quests');
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
