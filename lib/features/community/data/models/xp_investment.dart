// lib/features/community/data/models/xp_investment.dart
import 'package:floor/floor.dart';
import 'package:solo_leveling/global_data/converters/date_time_converter.dart';

@Entity(tableName: 'xp_investments')
class XpInvestment {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'questId')
  final String questId;
  
  @ColumnInfo(name: 'investorId')
  final String investorId;
  
  @ColumnInfo(name: 'xpAmount')
  final int xpAmount;
  
  @ColumnInfo(name: 'timestamp')
  @TypeConverters([DateTimeConverter])
  final DateTime timestamp;
  
  XpInvestment({
    this.id,
    required this.questId,
    required this.investorId,
    required this.xpAmount,
    required this.timestamp,
  });
}
