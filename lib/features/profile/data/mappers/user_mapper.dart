import 'package:solo_leveling/features/profile/domain/entities/user_entity.dart';
import 'package:solo_leveling/global_data/models/user.dart';


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
    );
  }

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
    );
  }
}