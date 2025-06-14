// quest_history.dart
import 'package:floor/floor.dart';

@entity
class QuestHistory {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int userId;
  final String questId;
  final DateTime completionDate;
  final int xpEarned;
  final int durationInSeconds;
  final double? distance; // Nullable (only for running quests)
  final int? repetitions; // Nullable (only for strength quests)

  QuestHistory({
    this.id,
    required this.userId,
    required this.questId,
    required this.completionDate,
    required this.xpEarned,
    required this.durationInSeconds,
    this.distance,
    this.repetitions,
  });
}
