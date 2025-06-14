import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/global_data/models/user.dart';
import 'package:solo_leveling/features/profile/data/mappers/user_mapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
  if (_formKey.currentState!.validate()) {
    final user = User(
      username: _usernameController.text,
      email: _emailController.text,
      age: int.parse(_ageController.text),
      lastActive: DateTime.now(),
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userEntity = UserMapper.mapUserToEntity(user);

    // Insert the user into the database
    final database = await getDatabase();
    await database.userDao.insertUser(user);

    // Then load the user
    await userProvider.loadUser(userEntity.username);

    // After saving the user, navigate to the next screen (e.g., quest list)
    Navigator.of(context).pushReplacementNamed('/quests');
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
