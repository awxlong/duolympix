//lib/global_data/database/xp_investment_dao.dart

/// Data Access Object (DAO) for managing XP investments
/// 
/// This DAO provides database operations for [XpInvestment] entities,
/// handling the storage, retrieval, and aggregation of XP investments
/// made by users on specific quests. Uses Floor ORM annotations to
/// generate SQL queries automatically.
library;
import 'package:floor/floor.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';

/// DAO for [XpInvestment] database operations
/// 
/// Defines methods for inserting, querying, and deleting XP investments.
/// All methods return Futures to handle asynchronous database operations.
@dao
abstract class XpInvestmentDao {
  /// Inserts a new XP investment into the database
  /// 
  /// [investment]: The [XpInvestment] object to be stored
  /// Returns: A [Future] that resolves to the row ID of the inserted record
  @insert
  Future<int> insertXpInvestment(XpInvestment investment);
  
  /// Retrieves all XP investments associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to filter investments by
  /// Returns: A [Future] with a list of [XpInvestment] objects, sorted by timestamp descending
  /// Use case: Display the investment history for a quest, newest first
  @Query('SELECT * FROM xp_investments WHERE questId = :questId ORDER BY timestamp DESC')
  Future<List<XpInvestment>> getInvestmentsByQuestId(String questId);
  
  /// Calculates the total XP invested in a specific quest
  /// 
  /// [questId]: The ID of the quest to sum investments for
  /// Returns: A [Future] with the total XP amount as an integer, or null if no investments exist
  /// Use case: Determine the current value of a quest based on accumulated investments
  @Query('SELECT SUM(xpAmount) FROM xp_investments WHERE questId = :questId')
  Future<int?> getTotalXpInvestedByQuestId(String questId);
  
  /// Deletes all XP investments associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to delete investments for
  /// Returns: A [Future] that completes when the deletion is finished
  /// Use case: Clean up investments when a quest is removed or reset
  @Query('DELETE FROM xp_investments WHERE questId = :questId')
  Future<void> deleteInvestmentsByQuestId(String questId);
}
