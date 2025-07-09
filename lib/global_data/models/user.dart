// lib/global_data/models/user.dart (Database Entity)
/// User Database Entity
/// 
/// Represents the user data structure as stored in the local database.
/// This is a persistence model optimized for database operations,
/// following the Floor ORM conventions. It contains all user-related
/// fields with mappings to appropriate database types and converters.
/// 
/// There are some differences worth mentioning with the UserEntity at 
/// lib/features/profile/domain/entities/user_entity.dart (Domain Entity)
/// 
/// Key Differences from UserEntity
/// 
/// 1. Purpose:
///    - UserEntity (Domain Layer): Represents core business logic and is independent of any persistence or presentation concerns.
///    - User (Database Layer): Optimized for database operations, with annotations for Floor ORM.
/// 
/// 2. Annotations:
///    - UserEntity: No database-specific annotations.
///    - User: Uses @entity, @PrimaryKey, @ColumnInfo, and @TypeConverters for database mapping.
/// 
/// 3. Data Conversion:
///    - UserEntity: Has business logic methods like purchaseProduct() that interact with domain models.
///    - User: Includes JSON serialization/deserialization methods (fromJson/toJson) for database operations.
/// 
/// 4. Dependencies:
///    - UserEntity: Depends on domain-level entities (e.g., Product from domain layer).
///    - User: Depends on data-layer models (e.g., ProductModel from data layer).
/// 
/// 5. Persistence Concerns:
///    - UserEntity: Does not handle database-specific details like column names or converters.
///    - User: Explicitly maps to database columns and includes type conversions (e.g., DateTimeConverter).
/// 
/// 6. Usage:
///    - UserEntity: Used throughout the application for business logic and UI rendering.
///    - User: Used exclusively for database interactions via the repository layer.
/// 
/// 7. Password Handling:
///    - Both classes include password field, but in production:
///      - UserEntity: Should use a hashed password for security.
///      - User: Should ensure proper encryption before storage.
/// 
/// 8. Conversion Between Layers:
///    - Use mappers (e.g., UserMapper) to convert between UserEntity and User:
///      - UserMapper.mapEntityToUser(): Converts domain entity to database model.
///      - UserMapper.mapUserToEntity(): Converts database model to domain entity.
/// 
/// There is a mapper class at lib/features/profile/data/mappers/user_mapper.dart which 
/// converts User to UserEntity and vice versa.
library;
import 'package:floor/floor.dart';
import 'package:duolympix/features/shopping/data/models/product_model.dart';
import 'package:duolympix/global_data/converters/date_time_converter.dart';

/// Database entity for user data
/// 
/// Maps directly to the 'User' table in the SQLite database.
/// Contains fields for user profile, progress tracking, and authentication.
@entity
class User {
  /// Auto-generated primary key for the user record
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  /// User's unique username (required)
  final String username;
  
  /// User's email address (optional)
  final String? email;
  
  /// User's age (optional)
  final int? age;
  
  /// User's gender (optional)
  final String? gender;
  
  /// User's weight in kilograms (optional)
  final double? weight;
  
  /// User's height in centimeters (optional)
  final double? height;
  
  /// Path or URL to user's profile picture (optional)
  final String? profilePicture;
  
  /// Total accumulated XP points
  final int totalXp;
  
  /// User's current level based on XP
  final int level;
  
  /// Current daily streak of completed quests
  final int streak;
  
  /// Total number of quests completed
  final int totalQuestsCompleted;
  
  /// User's password (should be hashed in production)
  final String password;
  
  /// Timestamp of the user's last activity
  /// Stored as milliseconds since epoch using [DateTimeConverter]
  @ColumnInfo(name: 'INTEGER')
  @TypeConverters([DateTimeConverter])
  final DateTime lastActive;

  /// Creates a new User instance
  /// 
  /// All fields are required except those with default values.
  /// [totalXp], [level], [streak], and [totalQuestsCompleted] default to initial values.
  User({
    this.id,
    required this.username,
    this.email,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.profilePicture,
    this.totalXp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalQuestsCompleted = 0,
    required this.lastActive,
    required this.password,
  });

  /// Creates a copy of this User with optional field updates
  /// 
  /// Used for creating immutable updates to the user object.
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
    String? password,
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
      password: password ?? this.password,
    );
  }

  /// Creates a User instance from JSON data
  /// 
  /// Used for deserializing user data from database queries.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] as String,
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
      password: json['password'] as String? ?? '',
    );
  }

  /// Converts the User instance to JSON data
  /// 
  /// Used for serializing user data for database storage.
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
      'password': password,
    };
  }

  /// Handles product purchase business logic
  /// 
  /// Deducts product cost from user's XP if sufficient points are available.
  /// Returns a new User instance with updated XP balance.
  User purchaseProduct(Product product) {
    if (totalXp >= product.xpCost) {
      return copyWith(totalXp: totalXp - product.xpCost);
    }
    return this;
  }
}
