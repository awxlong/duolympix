// This file defines the Quest object with its properties
// and methods. It also includes the QuestType enum to categorize quests.

import 'package:flutter/material.dart';

enum QuestType { running, strength, mentalHealth, custom }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final Duration? targetDuration;
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
    this.targetDuration,
    this.targetDistance,
    this.xpReward = 100,
    this.creatorId,
    this.isPublic = false, // default to private task
    this.totalXpInvested = 0, // default to 0
  }) : assert((targetDuration != null) || (targetDistance != null), 
           'Must specify either duration or distance');

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
}