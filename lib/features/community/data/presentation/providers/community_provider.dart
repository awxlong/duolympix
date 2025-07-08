// lib/features/community/data/presentation/providers/community_provider.dart
/// Community State Management
/// 
/// Manages the state for community-related features, including colleague relationships,
/// XP investments, and quest comments. Coordinates with the [CommunityRepository] to
/// handle data operations and notifies listeners of state changes for UI updates.
/// Future extensions can include implementing advanced comment features:
///    - Add nested replies to comments
///    - Support media attachments in comments
///    - Add comment sorting (e.g., newest first, most liked)
library;
import 'package:flutter/material.dart';
import 'package:solo_leveling/features/community/data/models/colleague_relation.dart';
import 'package:solo_leveling/features/community/data/models/comment.dart';
import 'package:solo_leveling/features/community/data/models/xp_investment.dart';
import 'package:solo_leveling/features/community/data/repositories/community_repository.dart';

/// Enumerates possible states for community data operations
/// 
/// - initial: Default state before any operations
/// - loading: Data is being fetched or processed
/// - success: Operation completed successfully
/// - error: An error occurred during an operation
enum CommunityStatus { initial, loading, success, error }

/// Model class representing the community feature state
/// 
/// Holds data for colleagues, investments, comments, and operation status.
/// Immutable to ensure predictable state changes.
class CommunityState {
  /// Current status of community operations
  final CommunityStatus status;
  
  /// List of colleagues associated with a quest
  final List<ColleagueRelation>? colleagues;
  
  /// List of XP investments in a quest
  final List<XpInvestment>? investments;
  
  /// List of comments on a quest
  final List<Comment>? comments;
  
  /// Total XP invested in a quest
  final int totalXpInvested;
  
  /// Error message if an operation failed
  final String? errorMessage;

  /// Creates a CommunityState instance
  const CommunityState({
    required this.status,
    this.colleagues,
    this.comments,
    this.investments,
    this.totalXpInvested = 0,
    this.errorMessage,
  });

  /// Creates an initial CommunityState with default values
  factory CommunityState.initial() => const CommunityState(
        status: CommunityStatus.initial,
        colleagues: null,
        comments: null,
        investments: null,
        totalXpInvested: 0,
        errorMessage: null,
      );

  /// Creates a copy of CommunityState with optional field updates
  /// 
  /// Used to immutably update state while preserving unchanged values.
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

/// Provider for managing community feature state and operations
/// 
/// Extends ChangeNotifier to broadcast state changes to UI components.
/// Uses [CommunityRepository] to handle data operations and updates
/// state accordingly. Supports colleague management, XP investments,
/// and quest comments.
class CommunityProvider extends ChangeNotifier {
  /// Repository for community data operations
  final CommunityRepository _repository;
  
  /// Current state of community features
  CommunityState _state = CommunityState.initial();

  /// Constructor with required repository dependency
  CommunityProvider(this._repository);

  /// Getter for the current state
  CommunityState get state => _state;

  // ------------------------------
  // Colleague Relationship Methods
  // ------------------------------

  /// Fetches colleagues associated with a specific quest
  /// 
  /// Updates state to loading, retrieves data via repository,
  /// and updates state with results or errors. Notifies listeners
  /// after state changes.
  /// 
  /// [questId]: The ID of the quest to fetch colleagues for
  Future<void> fetchColleaguesByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.getColleaguesByQuest(questId);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (colleagues) {
        // Update state on success
        _state = _state.copyWith(
          status: CommunityStatus.success,
          colleagues: colleagues,
        );
        notifyListeners();
      },
    );
  }

  /// Adds a new colleague relationship to a quest
  /// 
  /// Updates state to loading, adds relationship via repository,
  /// and updates state with results or errors. Optimistically updates
  /// the local list of colleagues on success.
  /// 
  /// [relation]: The colleague relationship to add
  Future<void> addColleague(ColleagueRelation relation) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.addColleague(relation);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (_) async {
        // Optimistically update local state
        if (_state.colleagues != null) {
          _state.colleagues!.add(relation);
        }
        _state = _state.copyWith(status: CommunityStatus.success);
        notifyListeners();
      },
    );
  }

  // ------------------------------
  // XP Investment Methods
  // ------------------------------

  /// Fetches investments and total XP for a specific quest
  /// 
  /// Updates state to loading, retrieves data via repository,
  /// and updates state with combined results or errors.
  /// 
  /// [questId]: The ID of the quest to fetch investments for
  Future<void> fetchInvestmentsByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final investmentsResult = await _repository.getInvestmentsByQuest(questId);
    final totalXpResult = await _repository.getTotalXpInvestedByQuest(questId);
    
    investmentsResult.fold(
      (failure) {
        // Update state on investment fetch failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (investments) {
        totalXpResult.fold(
          (totalXpFailure) {
            // Update state on total XP fetch failure
            _state = _state.copyWith(
              status: CommunityStatus.error,
              errorMessage: totalXpFailure.message,
            );
            notifyListeners();
          },
          (totalXp) {
            // Update state with both investments and total XP
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

  /// Processes an XP investment in a quest
  /// 
  /// Updates state to loading, processes investment via repository,
  /// and updates state with results or errors. Optimistically updates
  /// the local list of investments and total XP on success.
  /// 
  /// [investment]: The XP investment to process
  Future<void> investXp(XpInvestment investment) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.investXp(investment);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (id) async {
        // Optimistically update local state
        if (_state.investments != null) {
          _state.investments!.insert(0, investment); // Add to top of list
        }
        _state = _state.copyWith(
          status: CommunityStatus.success,
          totalXpInvested: _state.totalXpInvested + investment.xpAmount,
        );
        notifyListeners();
      },
    );
  }

  // ------------------------------
  // Comment Methods
  // ------------------------------

  /// Fetches comments for a specific quest
  /// 
  /// Updates state to loading, retrieves comments via repository,
  /// and updates state with results or errors.
  /// 
  /// [questId]: The ID of the quest to fetch comments for
  Future<void> fetchCommentsByQuest(String questId) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.getCommentsByQuest(questId);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (comments) {
        // Update state on success
        _state = _state.copyWith(
          status: CommunityStatus.success,
          comments: comments,
        );
        notifyListeners();
      },
    );
  }

  /// Posts a new comment to a quest
  /// 
  /// Updates state to loading, posts comment via repository,
  /// and updates state with results or errors. Optimistically updates
  /// the local list of comments on success.
  /// 
  /// [comment]: The comment to post
  Future<void> postComment(Comment comment) async {
    _state = _state.copyWith(status: CommunityStatus.loading);
    notifyListeners();

    final result = await _repository.postComment(comment);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: CommunityStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (id) async {
        // Optimistically update local state
        if (_state.comments != null) {
          _state.comments!.insert(0, comment); // Add to top of list
        }
        _state = _state.copyWith(status: CommunityStatus.success);
        notifyListeners();
      },
    );
  }
}
