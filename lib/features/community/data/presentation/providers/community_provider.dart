// lib/features/community/data/presentation/providers/community_provider.dart
import 'package:flutter/material.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart';

enum CommunityStatus { initial, loading, success, error }

class CommunityState {
  final CommunityStatus status;
  final List<ColleagueRelation>? colleagues;
  final List<XpInvestment>? investments;
  final List<Comment>? comments;
  final int totalXpInvested;
  final String? errorMessage;

  const CommunityState({
    required this.status,
    this.colleagues,
    this.comments,
    this.investments,
    this.totalXpInvested = 0,
    this.errorMessage,
  });

  factory CommunityState.initial() => const CommunityState(
        status: CommunityStatus.initial,
        colleagues: null,
        comments: null,
        investments: null,
        totalXpInvested: 0,
        errorMessage: null,
      );

  CommunityState copyWith({
    CommunityStatus? status,
    List<ColleagueRelation>? colleagues,
    List<Comment>? comments,
    List<XpInvestment>? investments,
    int? totalXpInvested,
    String? errorMessage,
  }) {
    return CommunityState(
      status: status ?? this.status,
      colleagues: colleagues ?? this.colleagues,
      comments: comments ?? this.comments,
      investments: investments ?? this.investments,
      totalXpInvested: totalXpInvested ?? this.totalXpInvested,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CommunityProvider extends ChangeNotifier {
  final CommunityRepository _repository;
  CommunityState _state = CommunityState.initial();

  CommunityProvider(this._repository);

  CommunityState get state => _state;

  // 监督人相关方法
  Future<void> fetchColleaguesByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.getColleaguesByQuest(questId);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (colleagues) {
        _state = _state.copyWith(
          status: CommunityStatus.success,
          colleagues: colleagues,
        );
        notifyListeners();
      },
    );
  }

  Future<void> addColleague(ColleagueRelation relation) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.addColleague(relation);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (_) async {
        if (_state.colleagues != null) {
          _state.colleagues!.add(relation);
        }
        _state = _state.copyWith(status: CommunityStatus.success);
        notifyListeners();
      },
    );
  }

  // XP投资相关方法
  Future<void> fetchInvestmentsByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final investmentsResult = await _repository.getInvestmentsByQuest(questId);
    final totalXpResult = await _repository.getTotalXpInvestedByQuest(questId);
    
    investmentsResult.fold(
    (failure) {
      _state = _state.copyWith(
        status: CommunityStatus.error,
        errorMessage: failure.message,
      );
      notifyListeners();
    },
    (investments) {
      totalXpResult.fold(
        (totalXpFailure) {
          _state = _state.copyWith(
            status: CommunityStatus.error,
            errorMessage: totalXpFailure.message,
          );
          notifyListeners();
        },
        (totalXp) {
          _state = _state.copyWith(
            status: CommunityStatus.success,
            investments: investments,
            totalXpInvested: totalXp,
          );
          notifyListeners();
        },
      );
    },
  );
}

  Future<void> investXp(XpInvestment investment) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.investXp(investment);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (id) async {
        if (_state.investments != null) {
          _state.investments!.insert(0, investment);
        }
        _state = _state.copyWith(
          status: CommunityStatus.success,
          totalXpInvested: _state.totalXpInvested + investment.xpAmount,
        );
        notifyListeners();
      },
    );
  }

  // 评论相关方法
  Future<void> fetchCommentsByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.getCommentsByQuest(questId);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (comments) {
        _state = _state.copyWith(
          status: CommunityStatus.success,
          comments: comments,
        );
        notifyListeners();
      },
    );
  }

  Future<void> postComment(Comment comment) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.postComment(comment);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (id) async {
        if (_state.comments != null) {
          _state.comments!.insert(0, comment);
        }
        _state = _state.copyWith(status: CommunityStatus.success);
        notifyListeners();
      },
    );
  }
}