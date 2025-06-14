// lib/features/profile/data/providers/leaderboard_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/profile/domain/repositories/leaderboard_repository.dart';
import 'package:solo_leveling/features/profile/domain/usecases/get_leaderboard_usecase.dart';
import '../../../../global_data/models/leaderboard_entry.dart';
import '../../../../global_data/models/enums.dart';

class LeaderboardState {
  final bool isLoading;
  final List<LeaderboardEntry> topUsers;
  final String? error;
  final LeaderboardEntry? userRanking;
  final RankingType selectedType;

  const LeaderboardState({
    required this.isLoading,
    required this.topUsers,
    this.error,
    this.userRanking,
    required this.selectedType,
  });

  factory LeaderboardState.initial() => const LeaderboardState(
        isLoading: false,
        topUsers: [],
        selectedType: RankingType.allTime,
      );

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
class LeaderboardProvider extends ChangeNotifier {
  final GetLeaderboardUseCase _getLeaderboardUseCase;
  LeaderboardState _state = LeaderboardState.initial();

  LeaderboardProvider(this._getLeaderboardUseCase);

  LeaderboardState get state => _state;

  Future<void> loadTopUsers(RankingType type, int limit) async {
    _state = _state.copyWith(
      isLoading: true,
      selectedType: type,
      error: null,
    );

    // Use addPostFrameCallback to ensure notifyListeners is called after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    final result = await _getLeaderboardUseCase(type, limit);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        notifyListeners();
      },
      (entries) {
        _state = _state.copyWith(
          isLoading: false,
          topUsers: entries,
        );
        notifyListeners();
      },
    );
  }
}

// Provider definition
final leaderboardProvider = ChangeNotifierProvider<LeaderboardProvider>(
  create: (context) => LeaderboardProvider(
    GetLeaderboardUseCase(
      context.read<LeaderboardRepository>(),
    ),
  ),
);
