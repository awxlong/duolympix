//lib/features/community/data/repositories/community_repository.dart
/// Community Repository Interface
/// 
/// Defines the contract for community-related data operations, including colleague management,
/// XP investments, and quest comments. Serves as an abstraction between the domain layer
/// and data layer, isolating business logic from data source implementation details (e.g., API, database).
library;
import 'package:dartz/dartz.dart';
import 'package:duolympix/core/error/failure.dart';
import 'package:duolympix/features/community/data/models/colleague_relation.dart';
import 'package:duolympix/features/community/data/models/comment.dart';
import 'package:duolympix/features/community/data/models/xp_investment.dart';

/// Abstract base class for community data operations
/// 
/// Declares methods for managing collaborative features like colleague relationships,
/// XP investments in quests, and user comments. Uses Either from the dartz package to
/// explicitly handle success/failure cases, ensuring errors are propagated predictably.
abstract class CommunityRepository {
  // ------------------------------
  // Colleague Management Features
  // ------------------------------

  /// Adds a colleague relationship for a quest
  /// 
  /// [relation]: A [ColleagueRelation] object defining the user-quest association
  /// Returns: [Either] with [void] on success or [Failure] on error
  /// Use case: Allow users to collaborate on quests by adding each other as colleagues
  Future<Either<Failure, void>> addColleague(ColleagueRelation relation);

  /// Removes a colleague relationship from a quest
  /// 
  /// [relation]: The [ColleagueRelation] to remove
  /// Returns: [Either] with [void] on success or [Failure] on error
  /// Note: Requires the exact questId and colleagueId to identify the relationship
  Future<Either<Failure, void>> removeColleague(ColleagueRelation relation);

  /// Retrieves all colleagues associated with a specific quest
  /// 
  /// [questId]: The ID of the quest to fetch colleagues for
  /// Returns: [Either] with a list of [ColleagueRelation] on success or [Failure] on error
  /// Use case: Display all collaborators on a quest details page
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByQuest(String questId);

  /// Retrieves all quests a specific user is associated with as a colleague
  /// 
  /// [userId]: The ID of the user to fetch colleague relationships for
  /// Returns: [Either] with a list of [ColleagueRelation] on success or [Failure] on error
  /// Use case: Show a user's active collaborative quests
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByUser(String userId);

  // ------------------------------
  // XP Investment Features
  // ------------------------------

  /// Records an XP investment in a quest
  /// 
  /// [investment]: An [XpInvestment] object with quest ID, investor ID, and XP amount
  /// Returns: [Either] with the investment ID on success or [Failure] on error
  /// Use case: Let users contribute XP to support or boost quest rewards
  Future<Either<Failure, int>> investXp(XpInvestment investment);

  /// Retrieves all XP investments for a specific quest
  /// 
  /// [questId]: The ID of the quest to fetch investments for
  /// Returns: [Either] with a list of [XpInvestment] on success or [Failure] on error
  /// Use case: Display investment history on a quest page
  Future<Either<Failure, List<XpInvestment>>> getInvestmentsByQuest(String questId);

  /// Calculates the total XP invested in a specific quest
  /// 
  /// [questId]: The ID of the quest to sum investments for
  /// Returns: [Either] with the total XP amount on success or [Failure] on error
  /// Use case: Show the collective support for a quest
  Future<Either<Failure, int>> getTotalXpInvestedByQuest(String questId);

  // ------------------------------
  // Comment & Discussion Features
  // ------------------------------

  /// Posts a comment on a quest
  /// 
  /// [comment]: A [Comment] object with quest ID, author, content, and timestamp
  /// Returns: [Either] with the comment ID on success or [Failure] on error
  /// Use case: Enable user discussions about quest strategies or experiences
  Future<Either<Failure, int>> postComment(Comment comment);

  /// Retrieves all comments for a specific quest
  /// 
  /// [questId]: The ID of the quest to fetch comments for
  /// Returns: [Either] with a list of [Comment] on success or [Failure] on error
  /// Use case: Display user discussions on a quest details page
  Future<Either<Failure, List<Comment>>> getCommentsByQuest(String questId);

  /// Deletes all comments associated with a quest
  /// 
  /// [questId]: The ID of the quest to clear comments for
  /// Returns: [Either] with [void] on success or [Failure] on error
  /// Use case: Moderate inappropriate content or reset discussions
  Future<Either<Failure, void>> deleteCommentsByQuest(String questId);
}