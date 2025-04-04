import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solo_leveling/services/location_service.dart';
// import 'package:provider/provider.dart';
import '../data/models/quest_model.dart';
import '../data/repositories/quest_repository.dart';
import '../../../core/constants.dart';

class QuestProvider with ChangeNotifier {
  final QuestRepository _repository;
  final LocationService _locationService;
  
  Quest? _activeQuest;
  StreamSubscription<double>? _distanceSubscription;
  StreamSubscription<Position>? _positionStream;
  Timer? _timer;
  DateTime? _startTime;
  double _currentDistance = 0.0;
  String? _errorMessage;

  List<Quest> _availableQuests = [];
  List<Quest> _completedQuests = [];

  QuestProvider({
    required QuestRepository repository,
    required LocationService locationService,
  }) : _repository = repository,
       _locationService = locationService;

  Quest? get activeQuest => _activeQuest;
  double get currentDistance => _currentDistance;
  List<Quest> get availableQuests => _availableQuests;
  List<Quest> get completedQuests => _completedQuests;
  // Modify elapsedTime getter
    Duration get elapsedTime => _startTime != null 
    ? DateTime.now().difference(_startTime!)
    : Duration.zero;


  get errorMessage => _errorMessage;


  Future<void> initialize() async {
    _availableQuests = await _repository.getAvailableQuests();
    _completedQuests = await _repository.getCompletedQuests();
    notifyListeners();
  }

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

  void _startTimer() {
    _timer = Timer.periodic(AppConstants.timerInterval, (timer) {
      notifyListeners();
    });
  }

  Future<void> completeQuest() async {
  try {
    if (_activeQuest == null) return;

    final success = _validateCompletion();
    
    if (success) {
      await _repository.saveCompletedQuest(_activeQuest!);
      _completedQuests.add(_activeQuest!);
      notifyListeners(); // Force update before reset
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _resetQuest();
    notifyListeners();
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
    rethrow;
  }
}

  // update _validateCompletion method to check for atleast, and atmost conditions 
  bool _validateCompletion() {
    if (_activeQuest == null) return false;
    
    if (_activeQuest!.type == QuestType.running) {
      final distanceOK = _currentDistance >= _activeQuest!.targetDistance!;
      final timeOK = elapsedTime! <= _activeQuest!.targetDuration!;
      return distanceOK && timeOK;
    }
    
    if (_activeQuest!.type == QuestType.strength) {
      return elapsedTime! <= _activeQuest!.targetDuration!;
    }
    
    return false;
  }

  void _resetQuest() {
  _timer?.cancel();
  _distanceSubscription?.cancel();
  _positionStream?.cancel();
  // Keep _startTime until next quest starts
  _currentDistance = 0.0;
}

    
  @override
  void dispose() {
    _resetQuest();
    super.dispose();
  }
}