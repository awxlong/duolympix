// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:solo_leveling/core/injection/database_module.dart' as _i371;
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart'
    as _i449;
import 'package:solo_leveling/features/community/data/repositories/community_repository_impl.dart'
    as _i84;
import 'package:solo_leveling/features/profile/data/repositories/leaderboard_repository_impl.dart'
    as _i458;
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart'
    as _i397;
import 'package:solo_leveling/features/profile/data/repositories/user_repository_impl.dart'
    as _i961;
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart'
    as _i701;
import 'package:solo_leveling/features/profile/domain/usecases/complete_quest_usecase.dart'
    as _i586;
import 'package:solo_leveling/features/profile/domain/usecases/get_leaderboard_usecase.dart'
    as _i947;
import 'package:solo_leveling/features/profile/domain/usecases/get_user_usecase.dart'
    as _i1004;
import 'package:solo_leveling/global_data/database/app_database.dart' as _i77;
import 'package:solo_leveling/global_data/database/colleague_relation_dao.dart'
    as _i465;
import 'package:solo_leveling/global_data/database/comment_dao.dart' as _i157;
import 'package:solo_leveling/global_data/database/xp_investment_dao.dart'
    as _i535;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final databaseModule = _$DatabaseModule();
    await gh.singletonAsync<_i77.AppDatabase>(
      () => databaseModule.provideAppDatabase(),
      preResolve: true,
    );
    gh.lazySingleton<_i397.UserRepository>(
        () => _i961.UserRepositoryImpl(gh<_i77.AppDatabase>()));
    gh.factory<_i701.LeaderboardRepository>(
        () => _i458.LeaderboardRepositoryImpl(gh<_i77.AppDatabase>()));
    gh.factory<_i1004.GetUserUseCase>(
        () => _i1004.GetUserUseCase(gh<_i397.UserRepository>()));
    gh.factory<_i586.CompleteQuestUseCase>(
        () => _i586.CompleteQuestUseCase(gh<_i397.UserRepository>()));
    gh.lazySingleton<_i449.CommunityRepository>(
        () => _i84.CommunityRepositoryImpl(
              gh<_i465.ColleagueRelationDao>(),
              gh<_i535.XpInvestmentDao>(),
              gh<_i397.UserRepository>(),
              gh<_i157.CommentDao>(),
            ));
    gh.factory<_i947.GetLeaderboardUseCase>(
        () => _i947.GetLeaderboardUseCase(gh<_i701.LeaderboardRepository>()));
    return this;
  }
}

class _$DatabaseModule extends _i371.DatabaseModule {}
