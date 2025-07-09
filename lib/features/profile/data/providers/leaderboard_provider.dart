// lib/features/profile/data/providers/leaderboard_provider.dart
/// Leaderboard State Management
/// 
/// Manages the state and business logic for fetching and displaying leaderboard data.
/// Handles loading states, error handling, and provides data to UI components through
/// the provider pattern. Supports different ranking types (e.g., all-time, weekly) and
/// tracks user-specific rankings.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duolympix/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:duolympix/features/profile/domain/usecases/get_leaderboard_usecase.dart';
import 'package:duolympix/global_data/models/enums.dart';
import 'package:duolympix/global_data/models/leaderboard_entry.dart';

/// Represents the state of the leaderboard UI
/// 
/// Contains data about loading status, top users, errors, user's own ranking,
/// and the currently selected ranking type (e.g., all-time, weekly).
class LeaderboardState {
  /// Loading indicator for fetching leaderboard data
  final bool isLoading;
  
  /// List of top users on the leaderboard
  final List<LeaderboardEntry> topUsers;
  
  /// Error message if data fetch fails
  final String? error;
  
  /// User's own ranking entry
  final LeaderboardEntry? userRanking;
  
  /// Currently selected ranking type (e.g., all-time, weekly)
  final RankingType selectedType;

  /// Creates a LeaderboardState instance
  const LeaderboardState({
    required this.isLoading,
    required this.topUsers,
    this.error,
    this.userRanking,
    required this.selectedType,
  });

  /// Creates an initial/default LeaderboardState
  factory LeaderboardState.initial() => const LeaderboardState(
        isLoading: false,
        topUsers: [],
        selectedType: RankingType.allTime,
      );

  /// Creates a copy of the state with optional updated fields
  /// 
  /// Used to immutably update state fields while preserving existing values.
  LeaderboardState copyWith({
    bool? isLoading,
    List<LeaderboardEntry>? topUsers,
    String? error,
    LeaderboardEntry? userRanking,
    RankingType? selectedType,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      topUsers: topUsers ?? this.topUsers,
      error: error ?? this.error,
      userRanking: userRanking ?? this.userRanking,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

/// Provider for managing leaderboard state and operations
/// 
/// Extends ChangeNotifier to broadcast state changes to UI components.
/// Coordinates with the LeaderboardRepository via the GetLeaderboardUseCase
/// to fetch leaderboard data.
class LeaderboardProvider extends ChangeNotifier {
  /// Use case for fetching leaderboard data
  final GetLeaderboardUseCase _getLeaderboardUseCase;
  
  /// Current state of the leaderboard
  LeaderboardState _state = LeaderboardState.initial();

  /// Constructor with required dependencies
  LeaderboardProvider(this._getLeaderboardUseCase);

  /// Getter for the current state
  LeaderboardState get state => _state;

  /// Loads top users for the specified ranking type and limit
  /// 
  /// Updates state to loading, fetches data using the use case,
  /// and updates state with results or errors. Uses addPostFrameCallback
  /// to ensure UI updates are processed after the build phase.
  /// 
  /// [type]: The ranking type (e.g., all-time, weekly)
  /// [limit]: Number of top users to fetch
  Future<void> loadTopUsers(RankingType type, int limit) async {
    _state = _state.copyWith(
      isLoading: true,
      selectedType: type,
      error: null,
    );

    // Ensure UI updates are processed after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final result = await _getLeaderboardUseCase(type, limit);
    result.fold(
      (failure) {
        // Handle failure by updating state with error
        _state = _state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        notifyListeners();
      },
      (entries) {
        // Handle success by updating state with fetched data
        _state = _state.copyWith(
          isLoading: false,
          topUsers: entries,
        );
        notifyListeners();
      },
    );
  }
}

/// Provider definition for dependency injection
/// 
/// Configures the LeaderboardProvider with its dependencies
/// using the Provider package. This allows the provider to be
/// accessed throughout the app using context.watch or context.read.
final leaderboardProvider = ChangeNotifierProvider<LeaderboardProvider>(
  create: (context) => LeaderboardProvider(
    GetLeaderboardUseCase(
      context.read<LeaderboardRepository>(),
    ),
  ),
);
