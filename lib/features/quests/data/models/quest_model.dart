// This file defines the Quest object with its properties
// and methods. It also includes the QuestType enum to categorize quests.

import 'package:flutter/material.dart';

enum QuestType { distance, strength, mentalHealth, custom }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final Duration? targetDuration;
  final Duration? minDuration; 
  final Duration? maxDuration;
  final double? targetDistance;
  final int xpReward;
  final IconData icon;
  final String? creatorId; // for community support
  final bool isPublic; // for community
  final int totalXpInvested; // track total XP invested on someone

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
    this.isPublic = true, // default to private task
    this.totalXpInvested = 0, // default to 0
  }) : assert((minDuration != null || maxDuration != null) || (targetDistance != null), 
           'Must specify either duration or distance'),
           targetDuration = targetDuration ?? minDuration ?? maxDuration; // for timer display purposes

  bool get isTimeBased => targetDuration != null;
  bool get isDistanceBased => targetDistance != null;
  bool get isMentalHealth => type == QuestType.mentalHealth;
  
  // Add to Quest class to handle varying quest types
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quest && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Add copyWith method
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
    );
  }
}