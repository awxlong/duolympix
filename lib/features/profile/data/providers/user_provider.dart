// lib/features/profile/data/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../domain/usecases/complete_quest_usecase.dart';
import '../../../quests/data/models/quest_model.dart';

enum UserStatus { initial, loading, loaded, error }

class UserState {
  final UserStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const UserState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory UserState.initial() => const UserState(
        status: UserStatus.initial,
        user: null,
        errorMessage: null,
      );

  UserState copyWith({
    UserStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
// Extend ChangeNotifier here
class UserProvider extends ChangeNotifier {
  final GetUserUseCase _getUserUseCase;
  final CompleteQuestUseCase _completeQuestUseCase;
  UserState _state = UserState.initial();

  UserProvider(this._getUserUseCase, this._completeQuestUseCase);

  UserState get state => _state;

  Future<void> loadUser(String username) async {
  _state = _state.copyWith(status: UserStatus.loading);
  notifyListeners();
  
  final result = await _getUserUseCase(username);
  result.fold(
    (failure) {
      _state = _state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      );
      notifyListeners();
    },
    (user) {
      _state = _state.copyWith(
        status: UserStatus.loaded,
        user: user,
      );
      notifyListeners();
    },
  );
}

  Future<void> completeQuest(Quest quest) async {
    if (_state.user == null) return;
    
    final result = await _completeQuestUseCase(quest);
    result.fold(
      (failure) {
        _state = _state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (_) async {
        await loadUser(_state.user!.username);
      },
    );
  }

  // Add this method to dispose resources
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
// // Provider definition
// final userProvider = StateNotifierProvider<UserProvider, UserState>((ref) {
//   final getUserUseCase = ref.watch(getUserUseCaseProvider);
//   final completeQuestUseCase = ref.watch(completeQuestUseCaseProvider);
//   return UserProvider(getUserUseCase, completeQuestUseCase);
// });
