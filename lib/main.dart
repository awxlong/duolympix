/// Duolympix Application Entry File

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/app_theme.dart';
import 'package:solo_leveling/features/auth/presentation/screens/login_page.dart';
import 'package:solo_leveling/features/auth/presentation/screens/splash_screen.dart';
import 'package:solo_leveling/features/community/data/presentation/providers/community_provider.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository_impl.dart';
import 'package:solo_leveling/features/mental_health/data/repositories/chat_repository.dart';
import 'package:solo_leveling/features/mental_health/provider/chat_provider.dart';
import 'package:solo_leveling/features/profile/data/providers/leaderboard_provider.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/features/profile/data/repositories/leaderboard_repository_impl.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository_impl.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/features/profile/domain/usecases/complete_quest_usecase.dart';
import 'package:solo_leveling/features/profile/domain/usecases/get_leaderboard_usecase.dart';
import 'package:solo_leveling/features/profile/domain/usecases/get_user_usecase.dart';
import 'package:solo_leveling/features/quest_list_screen.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';
import 'package:solo_leveling/global_data/database/colleague_relation_dao.dart';
import 'package:solo_leveling/global_data/database/comment_dao.dart';
import 'package:solo_leveling/global_data/database/xp_investment_dao.dart';
import 'package:solo_leveling/injection_container.dart';
import 'features/profile/presentation/screens/leaderboard_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'services/location_service.dart';
import 'features/quests/data/repositories/local_quest_repository.dart';

/// This is the core startup function of the application, 
/// responsible for initializing the dependency injection system, database connection, 
/// and configuring the overall architecture of the application.
/// It adopts the Provider state management pattern and 
/// the dependency inversion principle to ensure loose coupling and testability among components.
/// 
/// Main functions include:
/// 1. Initialization of the dependency injection container
/// 2. Establishment of the database connection
/// 3. Registration of state management providers (Provider)
/// 4. Configuration of application theme and routing
/// 5. Setup of the startup interface
void main() async {
  // Ensure Flutter framework is initialized (required for async operations)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure dependency injection container to implement inversion of control
  configureDependencies(); // From injection_container.dart
  
  // Initialize SQLite database and create necessary table structures
  final database = await getDatabase(); // Initialize database

  // Register all dependencies and state management providers using MultiProvider
  runApp(
    MultiProvider(
      providers: [
        /// Database layer providers
        // Register application-level database instance (singleton via value)
        Provider<AppDatabase>.value(value: database),

        /// Repository layer providers
        // Register leaderboard data repository implementation
        Provider<LeaderboardRepository>(
          create: (context) => LeaderboardRepositoryImpl(context.read<AppDatabase>()),
        ),

        // TODO: Implement a ColleagueRelations widget to manage colleague relationships
        // Register colleague relationship data access object inspired by ‘达目标’ (yoobingo @ http://www.yoobingo.com/)
        Provider<ColleagueRelationDao>(
          create: (context) => context.read<AppDatabase>().colleagueRelationDao,
        ),

        // Register XP investment data access object
        Provider<XpInvestmentDao>(
          create: (context) => context.read<AppDatabase>().xpInvestmentDao,
        ),

        // Register comment data access object
        Provider<CommentDao>(
          create: (context) => context.read<AppDatabase>().commentDao,
        ),

        // Register user data repository implementation
        Provider<UserRepository>(
          create: (context) => UserRepositoryImpl(context.read<AppDatabase>()),
        ),

        /// Business logic layer providers
        // Register quest provider - manages user quest states
        ChangeNotifierProvider(
          create: (_) => QuestProvider(
            repository: LocalQuestRepository(),
            locationService: LocationService(),
          )..initialize(), // Initialize quest data on creation
        ),

        // Register chat provider - handles mental health chat functionality
        ChangeNotifierProvider(
          create: (context) => ChatProvider(
            ChatRepository(),
            Provider.of<QuestProvider>(context, listen: false),
          ),
        ),

        // Register user profile provider - manages user info and quest completion
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            getIt<GetUserUseCase>(),
            getIt<CompleteQuestUseCase>(),
            UserRepositoryImpl(context.read<AppDatabase>())
          ),
        ),

        // Register leaderboard provider - handles user rankings and scores
        ChangeNotifierProvider<LeaderboardProvider>(
          create: (context) => LeaderboardProvider(
            GetLeaderboardUseCase(
              context.read<LeaderboardRepository>(),
            ),
          ),
        ),
        
        // Register community feature providers
        Provider<CommunityRepository>(
          create: (context) => CommunityRepositoryImpl(
            context.read<ColleagueRelationDao>(),
            context.read<XpInvestmentDao>(),
            context.read<UserRepository>(),
            context.read<CommentDao>(),
            context.read<UserProvider>(),
          ),
        ),
        ChangeNotifierProvider<CommunityProvider>(
          create: (context) => CommunityProvider(
            context.read<CommunityRepository>(),
          ),
        ),
      ],
      child: const MyApp(), // Root application widget
    ),
  );
}


/// Root application widget
/// 
/// Configures global application properties:
/// - App name
/// - Theme configuration (uses custom dark theme)
/// - Initial splash screen
/// - Predefined route table
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DuoLympiX', // Application name
      theme: AppTheme.darkTheme, // App theme configuration
      
      // Use splash screen as initial view for data loading
      home: const SplashScreen(),

      // Define application route table for navigation management
      routes: {
        '/quests': (context) => const QuestListScreen(), // Quest list page
        '/profile': (context) => const ProfileScreen(), // User profile page
        '/leaderboard': (context) => const LeaderboardScreen(), // Leaderboard page
        '/login': (context) => const LoginPage(), // Login page
      },
    );
  }
}