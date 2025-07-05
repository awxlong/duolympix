/// Solo Leveling 应用入口文件
/// 
/// 这是应用的核心启动文件，负责初始化依赖注入系统、数据库连接，并配置应用的整体架构。
/// 采用了Provider状态管理模式和依赖倒置原则，确保各组件间的松耦合和可测试性。
/// 
/// 主要功能包括：
/// - 依赖注入容器的初始化
/// - 数据库连接的建立
/// - 状态管理提供者(Provider)的注册
/// - 应用主题和路由的配置
/// - 启动界面的设置
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
/// 
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

        // Register LeaderboardRepository
        Provider<LeaderboardRepository>(
          create: (context) => LeaderboardRepositoryImpl(context.read<AppDatabase>()),
        ),

        // Register ColleagueRelationDao
        Provider<ColleagueRelationDao>(
          create: (context) => context.read<AppDatabase>().colleagueRelationDao,
        ),

        // Register XpInvestmentDao
        Provider<XpInvestmentDao>(
          create: (context) => context.read<AppDatabase>().xpInvestmentDao,
        ),

        // Register CommentDao
        Provider<CommentDao>(
          create: (context) => context.read<AppDatabase>().commentDao,
        ),

        // Register UserRepository
        Provider<UserRepository>(
          create: (context) => UserRepositoryImpl(context.read<AppDatabase>()),
        ),

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
            UserRepositoryImpl(context.read<AppDatabase>())
          ),
        ),

        ChangeNotifierProvider<LeaderboardProvider>(
          create: (context) => LeaderboardProvider(
            GetLeaderboardUseCase(
              context.read<LeaderboardRepository>(),
            ),
          ),
        ),
        // 社区功能Provider
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
        '/login': (context) => const LoginPage(),
      },
    );
  }
}