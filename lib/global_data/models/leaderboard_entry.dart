
import 'package:floor/floor.dart';
import 'package:duolympix/global_data/converters/date_time_converter.dart';
import 'enums.dart';

@entity
class LeaderboardEntry {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String userId;
  final RankingType rankingType;
  final int score;
  final int rank;
  
  @ColumnInfo(name: 'INTEGER') // Store as milliseconds since epoch
  @TypeConverters([DateTimeConverter])
  final DateTime updatedAt;
  
  final bool isCurrentUser; // Default value, can be set later

  LeaderboardEntry({
    this.id,
    required this.userId,
    required this.rankingType,
    required this.score,
    required this.rank,
    required this.updatedAt,
    required this.isCurrentUser,
  });


}