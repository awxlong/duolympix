import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:solo_leveling/features/mental_health/data/models/chat_message.dart';
import 'package:solo_leveling/features/mental_health/data/repositories/chat_repository.dart';

import '../../quests/data/models/quest_model.dart';
import '../../quests/provider/quest_provider.dart';


class ChatProvider with ChangeNotifier {
  final ChatRepository _repository;
  final QuestProvider _questProvider;
  final List<ChatMessage> _messages = [];
  DateTime? _sessionStart;
  bool _isLoading = false;
  Timer? _sessionTimer;
  Duration? _targetDuration;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  Duration get elapsedTime => _sessionStart != null 
      ? DateTime.now().difference(_sessionStart!)
      : Duration.zero;
  bool get isSessionComplete => _targetDuration != null && 
      elapsedTime >= _targetDuration!;

  ChatProvider(this._repository, this._questProvider);


  Future<void> startSession(Quest quest) async {
    _sessionStart = DateTime.now();
    _targetDuration = quest.targetDuration;
    _messages.clear();
    _startTimer();
    notifyListeners();
    
    // Ensure quest is properly tracked
    if (!_questProvider.availableQuests.contains(quest)) {
      _questProvider.startQuest(quest);
    }
  }

  void _startTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isSessionComplete) {
        _sessionTimer?.cancel();
        if (!_questProvider.completedQuests.contains(_questProvider.activeQuest)) {
          _questProvider.completeQuest();
        }
      }
      notifyListeners(); // Ensure UI updates
    });
  }

  Future<void> sendMessage(String message) async {
    try {
      _isLoading = true;
      notifyListeners();

      _messages.add(ChatMessage(text: message, isUser: true));
      final response = await _repository.sendMessage(message);
      _messages.add(ChatMessage(text: response, isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}