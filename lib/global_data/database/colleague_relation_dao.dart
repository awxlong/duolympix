//lib/global_data/database/colleague_relation_dao.dart

/// Duolympix has a feature inspired by ‘达目标’ (yoobingo @ http://www.yoobingo.com/) where
/// users can form colleague relationships to support/supervise each other in completing quests.
/// 
/// Implemention-wise, this is a Data Access Object (DAO) for managing colleague relationships
/// 
/// This DAO provides database operations for [ColleagueRelation] entities,
/// handling the storage and retrieval of relationships between users (colleagues)
/// associated with specific quests. Uses Floor ORM annotations to generate
/// SQL queries automatically.
library;
import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';

/// DAO for [ColleagueRelation] database operations
/// 
/// Defines methods for inserting, deleting, and querying colleague relationships.
/// All methods return Futures to handle asynchronous database operations.
@dao
abstract class ColleagueRelationDao {
  /// Inserts a new colleague relationship into the database
  /// 
  /// [relation]: The [ColleagueRelation] object to be stored
  /// Returns: A [Future] that completes when the insertion is finished
  @insert
  Future<void> insertColleagueRelation(ColleagueRelation relation);
  
  /// Deletes a colleague relationship from the database
  /// 
  /// [relation]: The [ColleagueRelation] object to be removed
  /// Note: Requires the relation to have matching ID/primary key to identify the record
  /// Returns: A [Future] that completes when the deletion is finished
  @delete
  Future<void> deleteColleagueRelation(ColleagueRelation relation);
  
  /// Retrieves all colleague relationships associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to filter relationships by
  /// Returns: A [Future] with a list of [ColleagueRelation] objects linked to the quest
  /// Use case: Display all colleagues involved in a particular quest
  @Query('SELECT * FROM colleague_relations WHERE questId = :questId')
  Future<List<ColleagueRelation>> getColleaguesByQuestId(String questId);
  
  /// Retrieves all colleague relationships involving a specific user
  /// 
  /// [userId]: The ID of the user to filter relationships by (as a colleague)
  /// Returns: A [Future] with a list of [ColleagueRelation] objects where the user is a colleague
  /// Use case: Show all quests a user is involved in as a colleague
  @Query('SELECT * FROM colleague_relations WHERE colleagueId = :userId')
  Future<List<ColleagueRelation>> getColleaguesByUserId(String userId);
}
