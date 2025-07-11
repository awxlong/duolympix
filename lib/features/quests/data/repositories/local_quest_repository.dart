//lib/features/quests/data/repositories/local_quest_repository.dart

/// Local Quest Repository Implementation
/// 
/// A simple in-memory repository for managing quests, storing both available
/// and completed quests locally. Serves as a demonstration of quest data structure
/// and repository pattern implementation. In a production environment, this would
/// typically be replaced with a persistent storage solution (e.g., database, API).
library;
import 'package:flutter/material.dart';
import 'package:duolympix/features/quests/data/models/quest_model.dart';
import 'package:duolympix/features/quests/data/repositories/quest_repository.dart';

/// Local in-memory implementation of [QuestRepository]
/// 
/// Stores quests in memory using lists, with no persistent storage.
/// Suitable for prototyping and development, but not for production use
/// where data persistence is required.
class LocalQuestRepository implements QuestRepository {
  /// Predefined list of all available quests
  /// 
  /// Contains example quests across different types (running, strength, mental health).
  /// Each quest defines specific goals, constraints, and XP rewards.
  final List<Quest> _allQuests = [
    const Quest(
      id: 'run-1-mile',
      title: 'Speed Runner',
      type: QuestType.distance,
      icon: Icons.directions_run,
      description: 'Run 1 mile in under 10 minutes',
      targetDistance: 1.0,
      maxDuration: Duration(minutes: 10),
      xpReward: 200,
    ),
    const Quest(
      id: 'bike-1-mile',
      title: 'Bike Commuter',
      type: QuestType.distance,
      icon: Icons.pedal_bike,
      description: 'Bike 1 mile in under 45 minutes',
      minDuration: Duration(minutes: 45),
      targetDistance: 1.0,
      xpReward: 250,
    ),
    const Quest(
      id: 'plank-2-minutes',
      title: 'Plank Master',
      type: QuestType.strength,
      icon: Icons.fitness_center_outlined,
      description: 'Plank for at least 1 minute',
      minDuration: Duration(minutes: 1),
      xpReward: 250,
    ),
    const Quest(
      id: 'guide-meditation',
      title: 'Guided Meditation',
      type: QuestType.mentalHealth,
      icon: Icons.psychology_alt_outlined,
      description: 'Meditate for 5 minutes guided by a Chatbot',
      maxDuration: Duration(minutes: 5),
      xpReward: 100,
      prompt: """
    You are a calm and friendly meditation instructor guiding a relaxing meditation session.  
    Create a 5-minute guided meditation focused on deep relaxation, stress relief, and mindfulness.  
    Use a soothing and gentle tone throughout.  
    Include clear step-by-step instructions for breathing, body awareness, and mental focus.  
    Add brief pauses for reflection and gentle reminders to stay present.  
    Avoid complex jargon and keep the language simple and accessible.  
    End the meditation with positive affirmations and a smooth transition back to awareness. """
    ),
    const Quest(
      id: 'pullups-50',
      title: 'Power Training',
      type: QuestType.strength,
      icon: Icons.fitness_center,
      description: 'Complete 50 pullups in under 10 minutes',
      maxDuration: Duration(minutes: 10),
      xpReward: 120,
    ),
    const Quest(
      id: 'mental-health-5',
      title: 'Mental Health',
      type: QuestType.mentalHealth,
      icon: Icons.psychology,
      description: 'Chat about mental health for at least 5 minutes',
      minDuration: Duration(minutes: 5),
      xpReward: 120,
      prompt: """
    You are a therapist trained in Cognitive Behavioral Therapy (CBT). Your goal is to:
    1. Help identify negative thought patterns
    2. Guide reframing into positive ones
    3. Ask clarifying questions when needed
    4. Provide evidence-based CBT techniques
    Respond in a compassionate, non-judgmental tone. Keep responses under 3 sentences.
    """,
    ),
    const Quest(
      id: 'pushups-50',
      title: 'Power Training',
      type: QuestType.strength,
      icon: Icons.back_hand,
      description: 'Complete 50 pushups in under 10 minutes',
      maxDuration: Duration(minutes: 10),
      xpReward: 125,
    ),
  ];

  /// In-memory storage for completed quests
  /// 
  /// Tracks which quests have been finished by the user.
  final List<Quest> _completedQuests = [];

  /// Retrieves all available (uncompleted) quests
  /// 
  /// Filters out quests that exist in the [_completedQuests] list.
  /// Returns a Future to match the repository interface, enabling
  /// easy replacement with async data sources.
  @override
  Future<List<Quest>> getAvailableQuests() async {
    return _allQuests.where((quest) => 
      !_completedQuests.any((c) => c.id == quest.id)).toList();
  }

  /// Marks a quest as completed and stores it
  /// 
  /// Adds the quest to [_completedQuests] for future filtering.
  /// Returns a Future to support async storage implementations.
  @override
  Future<void> saveCompletedQuest(Quest quest) async {
    _completedQuests.add(quest);
  }

  /// Retrieves all completed quests
  /// 
  /// Returns the stored list of completed quests.
  @override
  Future<List<Quest>> getCompletedQuests() async {
    return _completedQuests;
  }
}

/// Suggested Quest Extensions for Future Development
/// 
/// To enhance user engagement, consider adding these diverse quests across categories:
/// 
/// 1. Running Quests:
/// - "City Explorer": Run 5km while visiting 3 distinct landmarks (integrate location check-ins)
/// - "Pace Challenger": Maintain a 6min/km pace for 3km (add pace monitoring)
/// - "Night Runner": Complete a 2-mile run between 8PM-5AM (time-based bonus XP)
/// - "Elevation Gain": Climb 500ft over 3 miles (use altitude tracking)
/// 
/// 2. Strength Quests:
/// - "Circuit Crusher": Complete 3 rounds of 10 pushups, 15 squats, 20 situps (timed circuit)
/// - "Plank Master": Hold a plank for 2 minutes (with posture detection)
/// - "Progressive Lifter": Do 3 sets of 8 reps with increasing weight (repetition tracking)
/// - "Bodyweight Blitz": Complete 100 total reps across 4 different exercises (mixed activity)
/// 
/// 3. Mental Health Quests:
/// - "Mindful Breathing": Practice guided deep breathing for 10 minutes (audio integration)
/// - "Gratitude Journal": Record 3 things you're grateful for (text input with prompts)
/// - "Digital Detox": Stay off social media for 2 hours (app usage tracking)
/// - "Meditation Marathon": Complete 7 consecutive days of 5-minute meditations (streak tracking)
/// 
/// 4. Custom/Hybrid Quests:
/// - "Active Commute": Walk or bike to work/school (location-based validation)
/// - "Adventure Challenge": Hike 3 miles with at least 30 minutes of strength training (combined activity)
/// - "Wellness Week": Complete 1 running, 1 strength, and 1 mental health quest in 7 days (multi-quest streak)
/// 
/// Implementation Tips:
/// - Add difficulty levels (Easy/Medium/Hard) with scaled XP rewards
/// - Include "daily bonus" quests that refresh every 24 hours
/// - Add social quests that can be completed with friends (multi-user tracking)
/// - Implement quest chains where completing one unlocks a related quest
/// - Add seasonal quests tied to holidays or events
