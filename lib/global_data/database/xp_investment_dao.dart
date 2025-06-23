import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';

@dao
abstract class XpInvestmentDao {
  @insert
  Future<int> insertXpInvestment(XpInvestment investment);
  
  @Query('SELECT * FROM xp_investments WHERE questId = :questId ORDER BY timestamp DESC')
  Future<List<XpInvestment>> getInvestmentsByQuestId(String questId);
  
  @Query('SELECT SUM(xpAmount) FROM xp_investments WHERE questId = :questId')
  Future<int?> getTotalXpInvestedByQuestId(String questId);
  
  @Query('DELETE FROM xp_investments WHERE questId = :questId')
  Future<void> deleteInvestmentsByQuestId(String questId);
}