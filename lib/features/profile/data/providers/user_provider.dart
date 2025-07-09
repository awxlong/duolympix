// lib/features/profile/data/providers/user_provider.dart
/// User State Management and Provider
/// 
/// This file defines the state management system for user-related data,
/// including state models, status tracking, and business logic for loading,
/// updating, and interacting with user data. It follows the provider pattern
/// to manage state and notify UI components of changes.
library;
import 'package:flutter/material.dart';
import 'package:duolympix/features/profile/data/repositories/user_repository.dart';
import 'package:duolympix/features/profile/domain/entities/user_entity.dart';
import 'package:duolympix/features/profile/domain/usecases/complete_quest_usecase.dart';
import 'package:duolympix/features/profile/domain/usecases/get_user_usecase.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';

/// Enumerates possible states for user data loading/processing
/// 
/// - initial: Default state before any operations
/// - loading: Data is being fetched or processed
/// - loaded: Data has been successfully retrieved/updated
/// - error: An error occurred during an operation
enum UserStatus { initial, loading, loaded, error }

/// Model class representing the user state
/// 
/// Holds the current status, user data (if available), and error messages.
/// Immutable to ensure state changes are predictable and traceable.
class UserState {
  /// Current status of user data operations
  final UserStatus status;
  
  /// The user entity (domain model) when loaded
  final UserEntity? user;
  
  /// Error message if an operation failed
  final String? errorMessage;

  /// Creates a UserState instance
  const UserState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  /// Creates an initial UserState with default values
  factory UserState.initial() => const UserState(
        status: UserStatus.initial,
        user: null,
        errorMessage: null,
      );

  /// Creates a copy of UserState with optional field updates
  /// 
  /// Used to create new state instances when data changes, preserving
  /// unchanged fields from the previous state.
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

/// Provider for managing user state and operations
/// 
/// Extends ChangeNotifier to broadcast state changes to listeners.
/// Coordinates with use cases and repositories to handle user data
/// while maintaining a consistent state flow.
class UserProvider extends ChangeNotifier {
  /// Use case for fetching user data
  final GetUserUseCase _getUserUseCase;
  
  /// Use case for marking quests as completed for a user
  final CompleteQuestUseCase _completeQuestUseCase;
  
  /// Repository for direct user data operations
  final UserRepository _userRepository;
  
  /// Current state of user data and operations
  UserState _state = UserState.initial();

  /// Constructor with required dependencies
  /// 
  /// [_getUserUseCase]: Handles user retrieval logic
  /// [_completeQuestUseCase]: Handles quest completion logic
  /// [_userRepository]: Provides direct access to user data operations
  UserProvider(this._getUserUseCase, this._completeQuestUseCase, this._userRepository);

  /// Getter for the current state
  UserState get state => _state;

  /// Loads user data using credentials
  /// 
  /// Updates state to loading, attempts to fetch user via use case,
  /// and updates state based on success/error. Notifies listeners
  /// after state changes.
  /// 
  /// [username]: User's username for authentication
  /// [password]: User's password for authentication
  Future<void> loadUser(String username, String password) async {
    _state = _state.copyWith(status: UserStatus.loading);
    notifyListeners();
    
    final result = await _getUserUseCase(username, password);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (user) {
        // Update state on success
        _state = _state.copyWith(
          status: UserStatus.loaded,
          user: user,
        );
        notifyListeners();
      },
    );
  }

  /// Marks a quest as completed for the current user
  /// 
  /// Uses the complete quest use case, updates state based on results,
  /// and reloads user data to reflect changes. Notifies listeners
  /// throughout the process.
  /// 
  /// [quest]: The quest to mark as completed
  Future<void> completeQuest(Quest quest) async {
    if (_state.user == null) return; // Exit if no user is loaded

    final result = await _completeQuestUseCase(quest, _state.user!.username);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (_) async {
        // Reload user data to reflect updated stats
        await loadUser(_state.user!.username, _state.user!.password);
        notifyListeners();
      },
    );
  }

  /// Updates user profile data
  /// 
  /// Updates state to loading, attempts to update user via repository,
  /// and reloads user data on success. Handles errors by updating state.
  /// 
  /// [user]: The updated user entity to persist
  Future<void> updateUser(UserEntity user) async {
    _state = _state.copyWith(status: UserStatus.loading);
    notifyListeners();

    final result = await _userRepository.updateUser(user);
    result.fold(
      (failure) {
        // Update state on failure
        _state = _state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
      (_) async {
        // Reload user data to confirm update
        await loadUser(user.username, user.password);
        notifyListeners();
      },
    );
  }

  /// Cleans up resources when provider is disposed
  /// 
  /// Override to add any necessary cleanup (e.g., canceling subscriptions)
  @override
  void dispose() {
    // Add cleanup logic here if needed (e.g., cancel pending requests)
    super.dispose();
  }
}
