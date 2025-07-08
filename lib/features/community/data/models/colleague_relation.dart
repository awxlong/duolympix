// lib/features/community/data/models/colleague_relation.dart

/// Duolympix has a feature inspired by ‘达目标’ (yoobingo @ http://www.yoobingo.com/) where
/// users can form colleague relationships to support/supervise each other in completing quests.
/// 
/// Implemention-wise, this is an entity representing a colleague relationship linked to a quest
/// 
/// This class models a many-to-many relationship between users (colleagues)
/// and quests, tracking which users are associated with specific quests.
/// Serves as a junction table to manage collaborative quest participation.
library;
import 'package:floor/floor.dart';

/// Database entity for colleague-quest relationships
/// 
/// Maps to the 'colleague_relations' table, using a composite primary key
/// (questId + colleagueId) to ensure unique relationships between users and quests.
@Entity(
  tableName: 'colleague_relations',
  primaryKeys: ['questId', 'colleagueId'] // Composite key prevents duplicate relationships
)
class ColleagueRelation {
  /// ID of the quest associated with this colleague relationship
  /// 
  /// Part of the composite primary key. Links to the quest that the colleague is participating in.
  @ColumnInfo(name: 'questId')
  final String questId;
  
  /// ID of the colleague (user) in this relationship
  /// 
  /// Part of the composite primary key. Identifies the user associated with the quest.
  @ColumnInfo(name: 'colleagueId')
  final String colleagueId;
  
  /// Constructor for creating a colleague-quest relationship
  /// 
  /// Both [questId] and [colleagueId] are required to form the relationship.
  /// The composite primary key ensures a user cannot be added multiple times to the same quest.
  ColleagueRelation({
    required this.questId,
    required this.colleagueId,
  });
}

