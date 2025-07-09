// lib/features/profile/data/mappers/user_mapper.dart
/// Entity which converts between User model and UserEntity.
library;
import 'package:duolympix/features/profile/domain/entities/user_entity.dart';
import 'package:duolympix/global_data/models/user.dart';

/// Mapper class to convert between User and UserEntity
class UserMapper {
  static UserEntity mapUserToEntity(User user) {
    return UserEntity(
      id: user.id,
      username: user.username,
      email: user.email,
      age: user.age,
      gender: user.gender,
      weight: user.weight,
      height: user.height,
      profilePicture: user.profilePicture,
      totalXp: user.totalXp,
      level: user.level,
      streak: user.streak,
      totalQuestsCompleted: user.totalQuestsCompleted,
      lastActive: user.lastActive,
      password: user.password,
    );
  }
  
  /// Converts a UserEntity to a User model
  static User mapEntityToUser(UserEntity entity) {
    return User(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      age: entity.age,
      gender: entity.gender,
      weight: entity.weight,
      height: entity.height,
      profilePicture: entity.profilePicture,
      totalXp: entity.totalXp,
      level: entity.level,
      streak: entity.streak,
      totalQuestsCompleted: entity.totalQuestsCompleted,
      lastActive: entity.lastActive,
      password: entity.password,
    );
  }
}