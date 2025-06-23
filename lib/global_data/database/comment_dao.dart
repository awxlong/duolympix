import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';

@dao
abstract class CommentDao {
  @insert
  Future<int> insertComment(Comment comment);
  
  @Query('SELECT * FROM comments WHERE questId = :questId ORDER BY timestamp DESC')
  Future<List<Comment>> getCommentsByQuestId(String questId);
  
  @Query('DELETE FROM comments WHERE questId = :questId')
  Future<void> deleteCommentsByQuestId(String questId);
}