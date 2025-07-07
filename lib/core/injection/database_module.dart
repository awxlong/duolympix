// lib/core/injection/database_module.dart
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/global_data/database/app_database.dart';

@module
abstract class DatabaseModule {
  // Factory method to provide AppDatabase
  @singleton
  @preResolve
  Future<AppDatabase> provideAppDatabase() async {
    return $FloorAppDatabase.databaseBuilder('duolympix.db').build();
  }
}
