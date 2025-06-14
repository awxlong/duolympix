// user_dao.dart
import 'package:floor/floor.dart';
import 'package:solo_leveling/global_data/models/user.dart';
// import '/features/profile/data/models/user.dart'; // lib/features/profile/data/models/user.dart

@dao
abstract class UserDao {
  @Query('SELECT * FROM User WHERE id = :id')
  Future<User?> findUserById(int id);

  @Query('SELECT * FROM User WHERE email = :email')
  Future<User?> findUserByEmail(String email);

  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);
}
