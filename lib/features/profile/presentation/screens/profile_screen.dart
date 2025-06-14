import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userState = userProvider.state;

    if (userState.status == UserStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userState.status == UserStatus.error) {
      return Center(child: Text('Error: ${userState.errorMessage}'));
    }

    if (userState.user == null) {
      return const Center(child: Text('No user data'));
    }

    final user = userState.user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            const SizedBox(height: 20),
            Text(
              user.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Level: ${user.level}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('XP: ${user.totalXp}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Streak: ${user.streak}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Total Quests Completed: ${user.totalQuestsCompleted}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/leaderboard');
              },
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}
