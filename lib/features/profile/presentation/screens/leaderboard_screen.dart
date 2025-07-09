// lib/features/profile/presentation/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duolympix/features/profile/data/providers/leaderboard_provider.dart';
import 'package:duolympix/features/profile/presentation/screens/user_quests_screen.dart';
import 'package:duolympix/global_data/models/enums.dart'; 

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  void _loadLeaderboard() {
    final provider = Provider.of<LeaderboardProvider>(context, listen: false);
    provider.loadTopUsers(RankingType.allTime, 10);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<LeaderboardProvider>(context).state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          PopupMenuButton<RankingType>(
            onSelected: (type) {
              final provider = Provider.of<LeaderboardProvider>(context, listen: false);
              provider.loadTopUsers(type, 10);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: RankingType.allTime,
                child: Text('All Time'),
              ),
              const PopupMenuItem(
                value: RankingType.weekly,
                child: Text('Weekly'),
              ),
              const PopupMenuItem(
                value: RankingType.monthly,
                child: Text('Monthly'),
              ),
            ],
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : ListView.builder(
                  itemCount: state.topUsers.length,
                  itemBuilder: (context, index) {
                    final entry = state.topUsers[index];
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
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserQuestsScreen(userId: entry.userId), // 跳转到用户任务详情页面
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
