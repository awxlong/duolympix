import 'package:dartz/dartz.dart';
import 'package:solo_leveling/core/error/failure.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';

abstract class CommunityRepository {
  // 同事功能
  Future<Either<Failure, void>> addColleague(ColleagueRelation relation);
  Future<Either<Failure, void>> removeColleague(ColleagueRelation relation);
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByQuest(String questId);
  Future<Either<Failure, List<ColleagueRelation>>> getColleaguesByUser(String userId);
  
  // XP投资功能
  Future<Either<Failure, int>> investXp(XpInvestment investment);
  Future<Either<Failure, List<XpInvestment>>> getInvestmentsByQuest(String questId);
  Future<Either<Failure, int>> getTotalXpInvestedByQuest(String questId);

  // 围观评论功能
  Future<Either<Failure, int>> postComment(Comment comment);
  Future<Either<Failure, List<Comment>>> getCommentsByQuest(String questId);
  Future<Either<Failure, void>> deleteCommentsByQuest(String questId);
}