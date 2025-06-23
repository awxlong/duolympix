// lib/features/community/data/models/colleague_relation.dart
import 'package:floor/floor.dart';

@Entity(
  tableName: 'colleague_relations',
  primaryKeys: ['questId', 'colleagueId']
)
class ColleagueRelation {
  @ColumnInfo(name: 'questId')
  final String questId;
  
  @ColumnInfo(name: 'colleagueId')
  final String colleagueId;
  
  ColleagueRelation({
    required this.questId,
    required this.colleagueId,
  });
}
