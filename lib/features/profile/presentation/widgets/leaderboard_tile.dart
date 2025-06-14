// lib/features/profile/presentation/widgets/leaderboard_tile.dart
import 'package:flutter/material.dart';
import '../../../../global_data/models/leaderboard_entry.dart';
// import '../../../../global_data/models/user.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardTile({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          entry.rank.toString(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(entry.userId),
      subtitle: Text('XP: ${entry.score}'),
      trailing: entry.isCurrentUser
          ? const Icon(Icons.star, color: Colors.yellow)
          : null,
    );
  }
}
