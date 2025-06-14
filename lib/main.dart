import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/app_theme.dart';
import 'package:solo_leveling/features/auth/presentation/screens/splash_screen.dart';
import 'package:solo_leveling/features/mental_health/data/repositories/chat_repository.dart';
import 'package:solo_leveling/features/mental_health/provider/chat_provider.dart';
import 'package:solo_leveling/features/profile/data/providers/leaderboard_provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/features/profile/domain/usecases/complete_quest_usecase.dart';
import 'package:solo_leveling/features/profile/domain/usecases/get_leaderboard_usecase.dart';
import 'package:solo_leveling/features/profile/domain/usecases/get_user_usecase.dart';
import 'package:solo_leveling/features/quest_list_screen.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/injection_container.dart';
import 'features/profile/presentation/screens/leaderboard_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'services/location_service.dart';
import 'features/quests/data/repositories/local_quest_repository.dart';

void main() async {
  // Initialize dependency injection and database before running the app
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies(); // From injection_container.dart
  final database = await getDatabase(); // Initialize database
  
  runApp(
    MultiProvider(
      providers: [
        // Database provider
        Provider<AppDatabase>.value(value: database),
        
        // Quest provider with dependencies
        ChangeNotifierProvider(
          create: (_) => QuestProvider(
            repository: LocalQuestRepository(),
            locationService: LocationService(),
          )..initialize(),
        ),
        
        // Chat provider with dependencies
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            ChatRepository(),
            Provider.of<QuestProvider>(context, listen: false),
          ),
        ),
        
        // User profile provider
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            getIt<GetUserUseCase>(),
            getIt<CompleteQuestUseCase>(),
          ),
        ),

        ChangeNotifierProvider<LeaderboardProvider>(
          create: (context) => LeaderboardProvider(
            GetLeaderboardUseCase(
              context.read<LeaderboardRepository>(),
    ),
  ),
),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Leveling',
      theme: AppTheme.darkTheme,
      // Use SplashScreen to load user data before showing quests
      home: const SplashScreen(),
      
      // Optional: Add routes for better navigation
      routes: {
        '/quests': (context) => const QuestListScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
      },
    );
  }
}
