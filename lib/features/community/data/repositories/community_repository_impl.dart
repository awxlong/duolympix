// lib/features/community/data/repositories/community_repository_impl.dart
/// Community Repository Implementation
/// 
/// Concrete implementation of [CommunityRepository] using local database DAOs
/// for managing colleague relationships, XP investments, and quest comments.
/// Handles data persistence, error handling, and business logic for community features.
library;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart';
import 'package:solo_leveling/features/profile/data/providers/user_provider.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart';
import 'package:solo_leveling/global_data/database/colleague_relation_dao.dart';
import 'package:solo_leveling/global_data/database/comment_dao.dart';
import 'package:solo_leveling/global_data/database/xp_investment_dao.dart';

/// Database-backed implementation of [CommunityRepository]
/// 
/// Uses Floor DAOs (Data Access Objects) for local storage operations.
/// Integrates with user repository for XP management during investments.
/// Handles database errors and converts them to [Failure] instances.
@Injectable(as: CommunityRepository)
class CommunityRepositoryImpl implements CommunityRepository {
  /// DAO for colleague relationship operations
  final ColleagueRelationDao _colleagueRelationDao;
  
  /// DAO for XP investment operations
  final XpInvestmentDao _xpInvestmentDao;
  
  /// Repository for user data operations (e.g., XP deduction)
  final UserRepository _userRepository;
  
  /// DAO for comment operations
  final CommentDao _commentDao;
  
  /// Provider for accessing current user state
  final UserProvider _userProvider;

  /// Constructor with injected dependencies
  /// 
  /// Dependencies are provided via dependency injection
  CommunityRepositoryImpl(
    this._colleagueRelationDao,
    this._xpInvestmentDao,
    this._userRepository,
    this._commentDao,
    this._userProvider,
  );

  // ------------------------------
  // Colleague Relationship Implementation
  // ------------------------------

  /// Adds a new colleague relationship to the database
  /// 
  /// Inserts the relationship using [ColleagueRelationDao].
  /// Returns [Right] on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, void>> addColleague(ColleagueRelation relation) async {
    try {
      await _colleagueRelationDao.insertColleagueRelation(relation);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Removes a colleague relationship from the database
  /// 
  /// Deletes the relationship using [ColleagueRelationDao].
  /// Returns [Right] on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, void>> removeColleague(ColleagueRelation relation) async {
    try {
      await _colleagueRelationDao.deleteColleagueRelation(relation);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Retrieves all colleagues associated with a quest
  /// 
  /// Fetches relationships using [ColleagueRelationDao] filtered by quest ID.
  /// Returns [Right] with list on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByQuest(String questId) async {
    try {
      final colleagues = await _colleagueRelationDao.getColleaguesByQuestId(questId);
      return Right(colleagues);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Retrieves all quest relationships for a specific user
  /// 
  /// Fetches relationships using [ColleagueRelationDao] filtered by user ID.
  /// Returns [Right] with list on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByUser(String userId) async {
    try {
      final colleagues = await _colleagueRelationDao.getColleaguesByUserId(userId);
      return Right(colleagues);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  // ------------------------------
  // Comment Implementation
  // ------------------------------

  /// Posts a new comment to a quest
  /// 
  /// Inserts the comment using [CommentDao] and returns the generated ID.
  /// Returns [Right] with ID on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, int>> postComment(Comment comment) async {
    try {
      final id = await _commentDao.insertComment(comment);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Retrieves all comments for a specific quest
  /// 
  /// Fetches comments using [CommentDao] filtered by quest ID.
  /// Returns [Right] with list on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, List<Comment>>> getCommentsByQuest(String questId) async {
    try {
      final comments = await _commentDao.getCommentsByQuestId(questId);
      return Right(comments);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Deletes all comments associated with a quest
  /// 
  /// Removes comments using [CommentDao] filtered by quest ID.
  /// Returns [Right] on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, void>> deleteCommentsByQuest(String questId) async {
    try {
      await _commentDao.deleteCommentsByQuestId(questId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  // ------------------------------
  // XP Investment Implementation
  // ------------------------------

  /// Processes an XP investment in a quest
  /// 
  /// 1. Verifies user has sufficient XP
  /// 2. Deducts XP from user's total
  /// 3. Records the investment in the database
  /// 
  /// Returns [Right] with investment ID on success, appropriate [Failure] on error.
  @override
  Future<Either<Failure, int>> investXp(XpInvestment investment) async {
    try {
      // Fetch current user to verify XP balance
      final userResult = await _userRepository.getUser(
        investment.investorId, 
        _userProvider.state.user!.password
      );
      
      if (userResult.isLeft()) {
        return Left(userResult.fold((l) => l, (r) => throw UnimplementedError()));
      }

      final user = userResult.fold((l) => throw UnimplementedError(), (r) => r);
      
      // Check for sufficient XP
      if (user.totalXp < investment.xpAmount) {
        return const Left(InsufficientXpFailure());
      }

      // Deduct XP from user
      final updatedUser = user.copyWith(totalXp: user.totalXp - investment.xpAmount);
      final updateResult = await _userRepository.updateUser(updatedUser);
      
      if (updateResult.isLeft()) {
        return Left(updateResult.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // Record the investment
      final id = await _xpInvestmentDao.insertXpInvestment(investment);

      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Retrieves all XP investments for a specific quest
  /// 
  /// Fetches investments using [XpInvestmentDao] filtered by quest ID.
  /// Returns [Right] with list on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, List<XpInvestment>>> getInvestmentsByQuest(String questId) async {
    try {
      final investments = await _xpInvestmentDao.getInvestmentsByQuestId(questId);
      return Right(investments);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Calculates total XP invested in a specific quest
  /// 
  /// Sums investments using [XpInvestmentDao] filtered by quest ID.
  /// Returns [Right] with total on success, [DatabaseFailure] on error.
  @override
  Future<Either<Failure, int>> getTotalXpInvestedByQuest(String questId) async {
    try {
      final totalXp = await _xpInvestmentDao.getTotalXpInvestedByQuestId(questId);
      return Right(totalXp ?? 0);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
