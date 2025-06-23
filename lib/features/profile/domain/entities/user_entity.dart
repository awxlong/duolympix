// lib/features/profile/domain/entities/user_entity.dart (Domain Entity)
import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:solo_leveling/features/profile/data/mappers/user_mapper.dart';
import 'package:solo_leveling/features/shopping/data/models/product_model.dart';
import 'package:solo_leveling/global_data/converters/date_time_converter.dart';
// import '../../../../global_data/models/enums.dart';

class UserEntity extends Equatable {
  final int? id;
  final String username;
  final String email;
  final int age;
  final String? gender;
  final double? weight;
  final double? height;
  final String? profilePicture;
  final int totalXp;
  final int level;
  final int streak;
  final int totalQuestsCompleted;
  @ColumnInfo(name: 'INTEGER') // Store as milliseconds since epoch
  @TypeConverters([DateTimeConverter])
  final DateTime lastActive;

  const UserEntity({
    this.id,
    required this.username,
    required this.email,
    required this.age,
    this.gender,
    this.weight,
    this.height,
    this.profilePicture,
    this.totalXp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalQuestsCompleted = 0,
    required this.lastActive,
  });

  UserEntity purchaseProduct(Product product) {
    final user = UserMapper.mapEntityToUser(this);
    final updatedUser = user.purchaseProduct(product);
    return UserMapper.mapUserToEntity(updatedUser);
  }

  UserEntity copyWith({
    int? id,
    String? username,
    String? email,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? profilePicture,
    int? totalXp,
    int? level,
    int? streak,
    int? totalQuestsCompleted,
    DateTime? lastActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      profilePicture: profilePicture ?? this.profilePicture,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        age,
        gender,
        weight,
        height,
        profilePicture,
        totalXp,
        level,
        streak,
        totalQuestsCompleted,
        lastActive,
      ];
}


