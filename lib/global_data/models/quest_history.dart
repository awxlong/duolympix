import 'package:floor/floor.dart';
import 'package:solo_leveling/global_data/converters/date_time_converter.dart';

@entity
class QuestHistory {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int userId;
  final String questId;

  @ColumnInfo(name: 'INTEGER') // Store as milliseconds since epoch
  @TypeConverters([DateTimeConverter])
  final DateTime completionDate;

  final int xpEarned;
  final int? durationInSeconds;
  final double? distance; // For running quests
  final int? repetitions; // For strength quests

  QuestHistory({
    this.id,
    required this.userId,
    required this.questId,
    required this.completionDate,
    required this.xpEarned,
    this.durationInSeconds,
    this.distance,
    this.repetitions,
  });
}