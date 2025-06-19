// lib/global_data/models/user.dart (Database Entity)

import 'package:floor/floor.dart';
import 'package:solo_leveling/features/shopping/data/models/product_model.dart';
import 'package:solo_leveling/global_data/converters/date_time_converter.dart';

@entity
class User {
  @PrimaryKey(autoGenerate: true)
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

  User({
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

  // Add copyWith method
  User copyWith({
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
    return User(
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

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'],
    username: json['username'] as String, // Ensure username is a String
    email: json['email'] as String? ?? '',
    age: json['age'] as int? ?? 0,
    gender: json['gender'] as String? ?? '',
    weight: json['weight']?.toDouble(),
    height: json['height']?.toDouble(),
    profilePicture: json['profilePicture'] as String? ?? '',
    totalXp: json['totalXp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    streak: json['streak'] as int? ?? 0,
    totalQuestsCompleted: json['totalQuestsCompleted'] as int? ?? 0,
    lastActive: DateTime.fromMillisecondsSinceEpoch(json['INTEGER'] as int),
  );
}


  // Optional: Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'profilePicture': profilePicture,
      'totalXp': totalXp,
      'level': level,
      'streak': streak,
      'totalQuestsCompleted': totalQuestsCompleted,
      'lastActive': lastActive.millisecondsSinceEpoch,
    };
  }

  // Method to purchase a product
  User purchaseProduct(Product product) {
    if (totalXp >= product.xpCost) {
      return copyWith(totalXp: totalXp - product.xpCost);
    }
    return this;
  }
}