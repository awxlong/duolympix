// lib/features/quests/data/models/quest_model.dart
/// Quest Model - Core Entity for User Challenges
/// 
/// Represents a quest/task that users can complete to earn XP (experience points)
/// and progress in the application. Supports multiple quest types (e.g., distance-based,
/// time-based, mental health) with flexible goal parameters and customization options.
library;
import 'package:flutter/material.dart';

/// Enumerates the different types of quests available
/// 
/// - distance: Quests focused on covering a specific distance (e.g., running, walking)
/// - strength: Quests focused on physical strength activities (e.g., weightlifting)
/// - mentalHealth: Quests focused on mental wellness (e.g., meditation, journaling)
/// - custom: User-created quests with personalized goals
enum QuestType { distance, strength, mentalHealth, custom }

/// Model class representing a user quest/task
/// 
/// Contains all metadata needed to define a quest, including goals, rewards,
/// and classification. Supports both time-based and distance-based challenges,
/// with validation to ensure consistent goal definition.
class Quest {
  /// Unique identifier for the quest
  final String id;
  
  /// Display name of the quest
  final String title;
  
  /// Detailed description of the quest (e.g., instructions, tips. For chatbot quests, this is the initial prompt engineering the chatbot)
  final String description;
  
  /// Classification of the quest (see [QuestType])
  final QuestType type;
  
  /// Exact target duration for time-based quests (e.g., 30 minutes)
  final Duration? targetDuration;
  
  /// Minimum acceptable duration for flexible time-based quests
  final Duration? minDuration;
  
  /// Maximum allowed duration for flexible time-based quests
  final Duration? maxDuration;
  
  /// Target distance for distance-based quests (e.g., 5 kilometers)
  final double? targetDistance;
  
  /// XP awarded upon successful completion
  final int xpReward;
  
  /// Visual icon representing the quest type/category
  final IconData icon;
  
  /// ID of the user who created the quest (for community features)
  final String? creatorId;
  
  /// Flag indicating if the quest is visible to other users
  final bool isPublic;
  
  /// Total XP invested in this quest by other users (community support)
  final int totalXpInvested;

  /// Prompt for mental health quests, used to initialize the chatbot session
  final String? prompt;

  /// Creates a Quest instance with validation
  /// 
  /// Ensures either duration parameters (target/min/max) or a target distance
  /// is provided. Automatically sets [targetDuration] to the first valid duration
  /// parameter (target → min → max) for consistent timer display.
  const Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.icon,
    this.description = '',
    Duration? targetDuration,
    this.minDuration,
    this.maxDuration,
    this.targetDistance,
    this.xpReward = 100,
    this.creatorId,
    this.isPublic = true,
    this.totalXpInvested = 0,
    String? prompt,
  }) : assert(
          (minDuration != null || maxDuration != null || targetDuration != null) || 
          (targetDistance != null),
          'Must specify either duration parameters (target/min/max) or a target distance',
        ),
        targetDuration = targetDuration ?? minDuration ?? maxDuration,
        prompt = prompt ?? description;
        

  /// Checks if the quest is time-based (uses duration parameters)
  bool get isTimeBased => targetDuration != null;

  /// Checks if the quest is distance-based (uses target distance)
  bool get isDistanceBased => targetDistance != null;

  /// Checks if the quest is classified as mental health
  bool get isMentalHealth => type == QuestType.mentalHealth;

  /// Equality check based on quest ID
  /// 
  /// Two quests are considered equal if they share the same ID, regardless of other fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quest && 
      runtimeType == other.runtimeType && 
      id == other.id;

  /// Hash code based on quest ID
  @override
  int get hashCode => id.hashCode;

  /// Creates a copy of the Quest with optional field updates
  /// 
  /// Useful for modifying specific quest properties while preserving others.
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    Duration? targetDuration,
    Duration? minDuration,
    Duration? maxDuration,
    double? targetDistance,
    int? xpReward,
    IconData? icon,
    String? creatorId,
    bool? isPublic,
    int? totalXpInvested,
    String? prompt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetDuration: targetDuration ?? this.targetDuration,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      targetDistance: targetDistance ?? this.targetDistance,
      xpReward: xpReward ?? this.xpReward,
      icon: icon ?? this.icon,
      creatorId: creatorId ?? this.creatorId,
      isPublic: isPublic ?? this.isPublic,
      totalXpInvested: totalXpInvested ?? this.totalXpInvested,
      prompt: prompt ?? this.prompt,
    );
  }
}
