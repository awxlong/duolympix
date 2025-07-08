// lib/features/quest_list_screen.dart
/// Quest List Screen
/// 
/// Main screen displaying the list of available quests, with navigation to
/// quest details, quest creation, and other app sections via a bottom navigation bar.
/// Serves as the central hub for accessing quest-related features and user profile.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/auth/presentation/screens/login_page.dart';
import 'package:solo_leveling/features/profile/presentation/screens/profile_screen.dart';
import 'package:solo_leveling/features/quest_design_screen.dart';
import 'package:solo_leveling/features/quest_detail_screen.dart';
import 'package:solo_leveling/features/shopping/presentation/screens/shopping_screen.dart';
import 'mental_health/provider/chat_provider.dart';
import 'quests/data/models/quest_model.dart';
import 'quests/provider/quest_provider.dart';
import 'quests/presentation/widgets/quest_card.dart';

/// Main screen with quest list and bottom navigation
/// 
/// Displays the quest list as the default view and provides navigation to
/// profile, shopping, and login screens via the bottom navigation bar.
/// Includes an "Add" button to create new quests.
class QuestListScreen extends StatefulWidget {
  const QuestListScreen({super.key});

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen> {
  /// Currently selected index in the bottom navigation bar
  int _selectedIndex = 0;

  /// List of widget options corresponding to bottom navigation items
  static const List<Widget> _widgetOptions = <Widget>[
    QuestListContent(),
    ProfileScreen(),
    ShoppingScreen(),
    LoginPage(),
  ];

  /// Handles bottom navigation item taps
  /// 
  /// Updates the selected index to switch between screen contents.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solo Leveling'),
        actions: [
          // Button to navigate to quest creation screen
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuestDesignScreen()),
              );
            },
          ),
        ],
      ),
      // Display the currently selected screen content
      body: _widgetOptions.elementAt(_selectedIndex),
      // Bottom navigation bar with app sections
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
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          )
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Content widget displaying the list of available quests
/// 
/// Uses the [QuestProvider] to fetch available quests and displays them
/// in a scrollable list using [QuestCard] widgets. Handles navigation to
/// quest details with type-specific initialization (e.g., starting chat sessions
/// for mental health quests).
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

          // Handle mental health quests with chat session initialization
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
            // Start regular quest tracking
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

/// Suggested Extensions for Future Development
/// 
/// 1. Quest Filtering & Sorting:
///    - Add filter buttons for quest types (distance, strength, etc.)
///    - Implement sorting options (by XP reward, duration, alphabetical)
///    - Add search functionality to find specific quests
///    - Include filters for completed/incomplete quests
/// 
/// 2. Enhanced Navigation:
///    - Add a drawer menu for additional navigation options
///    - Implement deep linking to specific quests
///    - Add breadcrumb navigation for nested screens
///    - Support swipe gestures to navigate between sections
/// 
/// 3. User Experience Improvements:
///    - Add pull-to-refresh functionality for quest lists
///    - Implement empty state handling (e.g., "No quests available")
///    - Add loading indicators for quest data fetching
///    - Include quest recommendations based on user activity
/// 
/// 4. Personalization Features:
///    - Add "favorite" quests functionality
///    - Implement quest categories for better organization
///    - Support custom quest tags for personal organization
///    - Add recently accessed quests section
/// 
/// 5. Performance Optimizations:
///    - Implement lazy loading for large quest lists
///    - Add caching for frequently accessed quest data
///    - Optimize list rendering with recycling
///    - Support pagination for server-synced quests
/// 
/// 6. Social Features:
///    - Add "trending" or community quests section
///    - Implement quest sharing options
///    - Show colleague activity on shared quests
///    - Add leaderboards for quest completion
/// 
