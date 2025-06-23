import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';


@dao
abstract class ColleagueRelationDao {
  @insert
  Future<void> insertColleagueRelation(ColleagueRelation relation);
  
  @delete
  Future<void> deleteColleagueRelation(ColleagueRelation relation);
  
  @Query('SELECT * FROM colleague_relations WHERE questId = :questId')
  Future<List<ColleagueRelation>> getColleaguesByQuestId(String questId);
  
  @Query('SELECT * FROM colleague_relations WHERE colleagueId = :userId')
  Future<List<ColleagueRelation>> getColleaguesByUserId(String userId);
}