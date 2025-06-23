// lib/features/community/data/models/comment.dart
import 'package:floor/floor.dart';
import 'package:solo_leveling/global_data/converters/date_time_converter.dart';

@Entity(tableName: 'comments')
class Comment {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'questId')
  final String questId;
  
  @ColumnInfo(name: 'userId')
  final String userId;
  
  @ColumnInfo(name: 'content')
  final String content;
  
  @ColumnInfo(name: 'timestamp')
  @TypeConverters([DateTimeConverter])
  final DateTime timestamp;
  
  Comment({
    this.id,
    required this.questId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });
}
