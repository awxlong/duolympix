//lib/global_data/database/comment_dao.dart
/// Duolympix has a feature inspired by ‘达目标’ (yoobingo @ http://www.yoobingo.com/) where
/// there's a public forum for users to discuss quest-related tips. Here, we implement a simple
/// comment section.
/// 
/// Implemention-wise, this is a Data Access Object (DAO) for managing comments on quests
/// 
/// This DAO provides database operations for [Comment] entities,
/// handling the storage, retrieval, and deletion of comments
/// associated with specific quests. Uses Floor ORM annotations
/// to generate SQL queries automatically.
library;
import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';

/// DAO for [Comment] database operations
/// 
/// Defines methods for inserting, querying, and deleting comments.
/// All methods return Futures to handle asynchronous database operations.
@dao
abstract class CommentDao {
  /// Inserts a new comment into the database
  /// 
  /// [comment]: The [Comment] object to be stored
  /// Returns: A [Future] that resolves to the row ID of the inserted comment
  @insert
  Future<int> insertComment(Comment comment);
  
  /// Retrieves all comments associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to filter comments by
  /// Returns: A [Future] with a list of [Comment] objects, sorted by timestamp descending
  /// Use case: Display comments on a quest page in reverse chronological order
  @Query('SELECT * FROM comments WHERE questId = :questId ORDER BY timestamp DESC')
  Future<List<Comment>> getCommentsByQuestId(String questId);
  
  /// Deletes all comments associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to delete comments for
  /// Returns: A [Future] that completes when the deletion is finished
  /// Use case: Clean up comments when a quest is removed
  @Query('DELETE FROM comments WHERE questId = :questId')
  Future<void> deleteCommentsByQuestId(String questId);
}
