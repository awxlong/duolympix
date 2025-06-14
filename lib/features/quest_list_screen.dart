// lib/features/quest_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/auth/presentation/screens/login_page.dart';
import 'package:solo_leveling/features/profile/presentation/screens/leaderboard_screen.dart';
import 'package:solo_leveling/features/profile/presentation/screens/profile_screen.dart';
import 'package:solo_leveling/features/quest_detail_screen.dart';
import 'mental_health/provider/chat_provider.dart';
import 'quests/data/models/quest_model.dart';
import 'quests/provider/quest_provider.dart';
import 'quests/presentation/widgets/quest_card.dart';

class QuestListScreen extends StatefulWidget {
  const QuestListScreen({super.key});

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    QuestListContent(),
    ProfileScreen(),
    LeaderboardScreen(),
    LoginPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solo Leveling')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Quests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class QuestListContent extends StatelessWidget {
  const QuestListContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestProvider>(context);

    return ListView.builder(
      itemCount: provider.availableQuests.length,
      itemBuilder: (context, index) => QuestCard(
        quest: provider.availableQuests[index],
        onStart: () async {
          final quest = provider.availableQuests[index];

          if (quest.type == QuestType.mentalHealth) {
            final chatProvider = context.read<ChatProvider>();
            await chatProvider.startSession(quest);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuestDetailScreen(quest: quest)),
              );
            }
          } else {
            await provider.startQuest(quest);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestDetailScreen(quest: quest),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
