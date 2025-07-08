//lib/features/mental_health/provider/chat_provider.dart
/// Chat Provider - State Management for Chat Sessions
/// 
/// Manages the state of chat sessions, including message history,
/// session timing, and quest completion tracking. Integrates with a chat repository
/// for message handling and coordinates with the quest provider to validate session goals.
library;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:solo_leveling/features/mental_health/data/models/chat_message.dart';
import 'package:solo_leveling/features/mental_health/data/repositories/chat_repository.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';

/// State provider for mental health chat functionality
/// 
/// Uses ChangeNotifier to broadcast state changes to UI components.
/// Handles chat session lifecycle, message exchange, and automatic quest completion
/// when session duration targets are met.
class ChatProvider with ChangeNotifier {
  /// Repository for handling chat message logic (e.g., API/database interactions)
  final ChatRepository _repository;
  
  /// Quest provider for tracking session progress against quest goals
  final QuestProvider _questProvider;
  
  /// In-memory list of chat messages in the current session
  final List<ChatMessage> _messages = [];
  
  /// Timestamp when the current chat session started
  DateTime? _sessionStart;
  
  /// Flag indicating if a message is being processed (e.g., waiting for response)
  bool _isLoading = false;
  
  /// Timer for tracking session duration and checking completion criteria
  Timer? _sessionTimer;
  
  /// Target duration required to complete the associated quest
  Duration? _targetDuration;

  /// Getter for the list of messages in the current session
  List<ChatMessage> get messages => _messages;
  
  /// Getter for loading state (e.g., while waiting for bot response)
  bool get isLoading => _isLoading;
  
  /// Getter for elapsed time since session started
  Duration get elapsedTime => _sessionStart != null 
      ? DateTime.now().difference(_sessionStart!)
      : Duration.zero;
  
  /// Getter to check if session has met the target duration
  bool get isSessionComplete => _targetDuration != null && 
      elapsedTime >= _targetDuration!;

  /// Constructor with required dependencies
  /// 
  /// [_repository]: Handles message sending/receiving logic
  /// [_questProvider]: Tracks quest progress for mental health sessions
  ChatProvider(this._repository, this._questProvider);

  /// Initializes a new chat session tied to a mental health quest
  /// 
  /// Starts timing the session, sets the target duration from the quest,
  /// clears previous messages, and ensures the quest is active in the quest provider.
  /// 
  /// [quest]: The mental health quest to associate with this session
  Future<void> startSession(Quest quest) async {
    _sessionStart = DateTime.now();
    _targetDuration = quest.targetDuration; // Assumes Quest has targetDuration for mental health
    _messages.clear();
    _startTimer();
    notifyListeners();
    
    // Ensure the quest is actively tracked in the quest provider
    if (!_questProvider.availableQuests.contains(quest)) {
      _questProvider.startQuest(quest);
    }
  }

  /// Starts a periodic timer to monitor session duration
  /// 
  /// Checks every second if the session has met the target duration.
  /// Automatically completes the quest when duration is met.
  void _startTimer() {
    _sessionTimer?.cancel(); // Prevent multiple timers
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isSessionComplete) {
        _sessionTimer?.cancel();
        // Complete quest if not already completed
        if (!_questProvider.completedQuests.contains(_questProvider.activeQuest)) {
          _questProvider.completeQuest();
        }
      }
      notifyListeners(); // Update UI with elapsed time
    });
  }

  /// Sends a user message and retrieves a response
  /// 
  /// Adds the user message to the chat history, fetches a response from the repository,
  /// and updates the UI. Handles loading state during processing.
  /// 
  /// [message]: The text message sent by the user
  Future<void> sendMessage(String message) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add user message to history
      _messages.add(ChatMessage(text: message, isUser: true));
      // Get response from repository (could be API, local bot, etc.)
      final response = await _repository.sendMessage(message);
      // Add bot response to history
      _messages.add(ChatMessage(text: response, isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cleans up resources when provider is disposed
  /// 
  /// Cancels active timers to prevent memory leaks
  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}
