// lib/features/profile/domain/entities/user_entity.dart (Domain Entity)
import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
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


