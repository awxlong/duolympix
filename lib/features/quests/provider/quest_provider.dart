//lib/features/quests/provider/quest_provider.dart
/// Quest Provider - State Management for Quest Operations
/// 
/// Manages the state of quests, including tracking active quests,
/// distance/time monitoring, and quest completion logic. Integrates
/// with location services for distance-based quests and coordinates
/// with the repository layer for data persistence.
/// 
/// Key responsibilities:
/// - Managing available/completed quest lists
/// - Tracking active quest progress (distance/time)
/// - Handling location permissions and tracking for running quests
/// - Validating quest completion criteria
/// - Notifying listeners of state changes
library;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:duolympix/core/constants.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';
import 'package:duolympix/features/quests/data/repositories/quest_repository.dart';
import 'package:duolympix/services/location_service.dart';


/// State provider for quest-related operations
/// 
/// Uses ChangeNotifier to broadcast state changes to UI components.
/// Integrates with [QuestRepository] for data persistence and
/// [LocationService] for distance tracking in running quests.
class QuestProvider with ChangeNotifier {
  /// Repository for quest data operations
  final QuestRepository _repository;
  
  /// Service for location tracking and distance calculations
  final LocationService _locationService;
  
  /// Currently active/ongoing quest (if any)
  Quest? _activeQuest;
  
  /// Subscription for distance updates during running quests
  StreamSubscription<double>? _distanceSubscription;
  
  /// Subscription for raw position updates (reserved for future use)
  StreamSubscription<Position>? _positionStream;
  
  /// Timer for updating elapsed time display
  Timer? _timer;
  
  /// Start time of the current active quest
  DateTime? _startTime;
  
  /// Current distance traveled in active running quest
  double _currentDistance = 0.0;
  
  /// Error message for location/quest tracking issues
  String? _errorMessage;

  /// List of all available quests
  List<Quest> _availableQuests = [];
  
  /// List of quests completed by the current user
  List<Quest> _completedQuests = [];

  /// Constructor with required dependencies
  /// 
  /// [repository]: Handles data persistence for quests
  /// [locationService]: Manages location tracking for distance-based quests
  QuestProvider({
    required QuestRepository repository,
    required LocationService locationService,
  }) : _repository = repository,
       _locationService = locationService;

  /// Getter for the currently active quest
  Quest? get activeQuest => _activeQuest;
  
  /// Getter for current distance in active running quest
  double get currentDistance => _currentDistance;
  
  /// Getter for all available quests
  List<Quest> get availableQuests => _availableQuests;
  
  /// Getter for all completed quests
  List<Quest> get completedQuests => _completedQuests;
  
  /// Getter for elapsed time since active quest started
  Duration get elapsedTime => _startTime != null 
      ? DateTime.now().difference(_startTime!)
      : Duration.zero;

  /// Getter for error messages (e.g., location permissions)
  get errorMessage => _errorMessage;

  /// Initializes quest data on provider creation
  /// 
  /// Loads available and completed quests from repository
  /// Triggers UI update after loading
  Future<void> initialize() async {
    _availableQuests = await _repository.getAvailableQuests();
    _completedQuests = await _repository.getCompletedQuests();
    notifyListeners();
  }

  /// Reloads completed quests from repository
  /// 
  /// Useful for refreshing data after quest completion
  Future<void> loadCompletedQuests() async {
    _completedQuests = await _repository.getCompletedQuests();
    notifyListeners();
  }

  /// Starts a new quest and initializes tracking
  /// 
  /// Resets tracking variables and starts appropriate monitoring:
  /// - Distance tracking for running quests
  /// - Timer for all quest types
  /// 
  /// [quest]: The quest to start
  Future<void> startQuest(Quest quest) async {
    _activeQuest = quest;
    _startTime = DateTime.now();
    _currentDistance = 0.0;

    if (quest.isDistanceBased) {
      await _startDistanceTracking();
    }

    _startTimer();
    notifyListeners();
  }

  /// Initializes location tracking for distance-based quests
  /// 
  /// Requests location permissions, checks service availability,
  /// and starts distance tracking from the user's current position.
  /// Handles errors by resetting the quest and propagating messages.
  Future<void> _startDistanceTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      final position = await _locationService.getCurrentPosition();
      _distanceSubscription = _locationService.trackDistance(position).listen(
        (distance) {
          _currentDistance = distance;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _resetQuest();
      notifyListeners();
      rethrow;
    }
  }

  /// Starts a periodic timer to update quest progress UI
  /// 
  /// Uses the app's standard timer interval from [AppConstants]
  void _startTimer() {
    _timer = Timer.periodic(AppConstants.timerInterval, (timer) {
      notifyListeners();
    });
  }

  /// Attempts to complete the current active quest
  /// 
  /// Validates completion criteria, saves to repository if successful,
  /// and resets quest tracking. Ensures UI updates properly during process.
  Future<void> completeQuest() async {
    try {
      if (_activeQuest == null) return;

      final success = _validateCompletion();
      
      if (success) {
        await _repository.saveCompletedQuest(_activeQuest!);
        _completedQuests.add(_activeQuest!);
        notifyListeners(); // Force update before reset
        await Future.delayed(const Duration(milliseconds: 100)); // Prevent UI flicker
      }

      _resetQuest();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Validates if the current quest meets completion criteria
  /// 
  /// Checks different conditions based on quest type:
  /// - Running: Requires minimum distance + time constraints (at most/at least)
  /// - Strength: Requires time constraints (at most/at least)
  /// 
  /// Returns: true if all criteria are met, false otherwise
  bool _validateCompletion() {
    if (_activeQuest == null) return false;
    
    if (_activeQuest!.type == QuestType.distance) {
      final distanceOK = _currentDistance >= _activeQuest!.targetDistance!;
      final timeOK = _activeQuest!.maxDuration != null 
         ? elapsedTime <= _activeQuest!.maxDuration! // "At most" time constraint
          : _activeQuest!.minDuration != null 
              ? elapsedTime >= _activeQuest!.minDuration! // "At least" time constraint
               : true;
      return distanceOK && timeOK;
    }
    
    if (_activeQuest!.type == QuestType.strength) {
      return _activeQuest!.maxDuration != null 
         ? elapsedTime <= _activeQuest!.maxDuration! // "At most" time constraint
          : _activeQuest!.minDuration != null 
              ? elapsedTime >= _activeQuest!.minDuration! // "At least" time constraint
               : true;
    }
    
    return false;
  }

  /// Resets quest tracking variables and stops monitoring
  /// 
  /// Cancels timers and location subscriptions, clears active quest
  /// but preserves start time until next quest begins (for reference)
  void _resetQuest() {
    _timer?.cancel();
    _distanceSubscription?.cancel();
    _positionStream?.cancel();
    _currentDistance = 0.0;
    _activeQuest = null;
    // _startTime remains until next quest starts
  }

  /// Adds a new quest to the available quests list
  /// 
  /// [quest]: The new quest to add
  void addNewQuest(Quest quest) {
    _availableQuests.add(quest);
    notifyListeners();
  }

  /// Retrieves completed quests for a specific user
  /// 
  /// [userId]: ID of the user to fetch completed quests for
  /// 
  /// Note: Current implementation reuses existing method - future versions
  /// should add repository-level filtering by userId
  Future<List<Quest>> getCompletedQuestsByUser(String userId) async {
    return await _repository.getCompletedQuests();
  }
  
  /// Retrieves uncompleted quests for a specific user
  /// 
  /// [userId]: ID of the user to fetch uncompleted quests for
  /// Calculates by subtracting completed quests from all available quests
  Future<List<Quest>> getUncompletedQuestsByUser(String userId) async {
    final allAvailableQuests = await _repository.getAvailableQuests();
    final completedQuests = await getCompletedQuestsByUser(userId);
    return allAvailableQuests.where((quest) => !completedQuests.any((c) => c.id == quest.id)).toList();
  }

  /// Cleans up resources when provider is disposed
  /// 
  /// Ensures all subscriptions and timers are cancelled to prevent leaks
  @override
  void dispose() {
    _resetQuest();
    super.dispose();
  }
}
