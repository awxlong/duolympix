// lib/features/community/data/repositories/community_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart';
import 'package:solo_leveling/features/profile/data/repositories/user_repository.dart';
import 'package:solo_leveling/global_data/database/colleague_relation_dao.dart';
import 'package:solo_leveling/global_data/database/comment_dao.dart';
import 'package:solo_leveling/global_data/database/xp_investment_dao.dart';

@Injectable(as: CommunityRepository)
class CommunityRepositoryImpl implements CommunityRepository {
  final ColleagueRelationDao _colleagueRelationDao;
  final XpInvestmentDao _xpInvestmentDao;
  final UserRepository _userRepository; // 用于扣除用户XP
  final CommentDao _commentDao; // 

  CommunityRepositoryImpl(
    this._colleagueRelationDao,
    this._xpInvestmentDao,
    this._userRepository,
    this._commentDao,
  );

  // 同事功能实现
  @override
  Future<Either<Failure, void>> addColleague(ColleagueRelation relation) async {
    try {
      await _colleagueRelationDao.insertColleagueRelation(relation);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeColleague(ColleagueRelation relation) async {
    try {
      await _colleagueRelationDao.deleteColleagueRelation(relation);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByQuest(String questId) async {
    try {
      final colleagues = await _colleagueRelationDao.getColleaguesByQuestId(questId);
      return Right(colleagues);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByUser(String userId) async {
    try {
      final colleagues = await _colleagueRelationDao.getColleaguesByUserId(userId);
      return Right(colleagues);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
  // 围观评论功能实现
  @override
  Future<Either<Failure, int>> postComment(Comment comment) async {
    try {
      final id = await _commentDao.insertComment(comment);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByQuest(String questId) async {
    try {
      final comments = await _commentDao.getCommentsByQuestId(questId);
      return Right(comments);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCommentsByQuest(String questId) async {
    try {
      await _commentDao.deleteCommentsByQuestId(questId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  // XP投资功能实现
  // Update the investXp method in community_repository_impl.dart
@override
  Future<Either<Failure, int>> investXp(XpInvestment investment) async {
    try {
      // 1. 扣除投资者的XP
      final userResult = await _userRepository.getUser(investment.investorId);
      if (userResult.isLeft()) {
        return Left(userResult.fold((l) => l, (r) => throw UnimplementedError()));
      }

      final user = userResult.fold((l) => throw UnimplementedError(), (r) => r);
      if (user.totalXp < investment.xpAmount) {
        return const Left(InsufficientXpFailure());
      }

      final updatedUser = user.copyWith(totalXp: user.totalXp - investment.xpAmount);
      final updateResult = await _userRepository.updateUser(updatedUser);
      if (updateResult.isLeft()) {
        return Left(updateResult.fold((l) => l, (r) => throw UnimplementedError()));
      }

      // 2. 记录XP投资
      final id = await _xpInvestmentDao.insertXpInvestment(investment);

      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<XpInvestment>>> getInvestmentsByQuest(String questId) async {
    try {
      final investments = await _xpInvestmentDao.getInvestmentsByQuestId(questId);
      return Right(investments);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

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
