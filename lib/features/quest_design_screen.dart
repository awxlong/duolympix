// lib/features/quest_design_screen.dart
/// Quest Design Screen
/// 
/// Allows users to create custom quests with configurable parameters such as
/// title, description, type, duration constraints, and target distance (for 
/// distance-based quests). Automatically calculates appropriate XP rewards
/// based on quest complexity and duration.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';

/// Screen for designing and creating custom quests
/// 
/// Provides a form interface for users to input quest details, select quest type,
/// set time constraints, and define target distance (if applicable). Automatically
/// generates appropriate XP rewards and icons based on quest parameters.
class QuestDesignScreen extends StatefulWidget {
  const QuestDesignScreen({super.key});

  @override
  State<QuestDesignScreen> createState() => _QuestDesignScreenState();
}

class _QuestDesignScreenState extends State<QuestDesignScreen> {
  /// Controller for the quest title input field
  final TextEditingController _titleController = TextEditingController();
  
  /// Controller for the quest description input field
  final TextEditingController _descriptionController = TextEditingController();
  
  /// Currently selected quest type (default: distance)
  QuestType _selectedType = QuestType.distance;
  
  /// Controller for the time value input field (in minutes)
  final TextEditingController _timeValueController = TextEditingController(text: '5');
  
  /// Flag indicating if the time constraint is an upper bound (true) or lower bound (false)
  bool _isUpperBound = true;
  
  /// Controller for the distance input field (for distance-based quests)
  final TextEditingController _distanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Your Quest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quest title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quest Title'),
            ),
            // Quest description input
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Quest Description'),
            ),
            // Quest type selection
            DropdownButton<QuestType>(
              value: _selectedType,
              onChanged: (newValue) {
                setState(() {
                  _selectedType = newValue!;
                });
              },
              items: QuestType.values.map((type) {
                return DropdownMenuItem<QuestType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ),
            // Distance input (only shown for distance-based quests)
            if (_selectedType == QuestType.distance)
              TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Miles to run'),
              ),
            // Time constraint type selection (upper or lower bound)
            Row(
              children: [
                const Text('Time Constraint: '),
                Radio<bool>(
                  value: true,
                  groupValue: _isUpperBound,
                  onChanged: (newValue) {
                    setState(() {
                      _isUpperBound = newValue!;
                    });
                  },
                ),
                const Text('At most'),
                Radio<bool>(
                  value: false,
                  groupValue: _isUpperBound,
                  onChanged: (newValue) {
                    setState(() {
                      _isUpperBound = newValue!;
                    });
                  },
                ),
                const Text('At least'),
              ],
            ),
            // Time value input (in minutes)
            TextField(
              controller: _timeValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time in minutes'),
            ),
            // Create quest button
            ElevatedButton(
              onPressed: () {
                _createQuest(context);
              },
              child: const Text('Create Quest'),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a new quest based on user inputs and adds it to the quest provider
  /// 
  /// Validates inputs, calculates appropriate XP reward, and generates a unique ID
  /// before creating the quest and navigating back to the previous screen.
  void _createQuest(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final title = _titleController.text;
    final description = _descriptionController.text;
    final type = _selectedType;
    final timeValue = int.tryParse(_timeValueController.text) ?? 5;
    final duration = Duration(minutes: timeValue);
    final minDuration = _isUpperBound ? null : duration;
    final maxDuration = _isUpperBound ? duration : null;
    final xpReward = _calculateXpReward(type, duration);
    final distance = _selectedType == QuestType.distance
       ? double.tryParse(_distanceController.text)
        : null;

    final newQuest = Quest(
      id: id,
      title: title,
      description: description,
      type: type,
      minDuration: minDuration,
      maxDuration: maxDuration,
      targetDistance: distance,
      icon: _getIconForType(type),
      xpReward: xpReward,
    );

    questProvider.addNewQuest(newQuest);
    Navigator.pop(context);
  }

  /// Calculates appropriate XP reward based on quest type and duration
  /// 
  /// Applies different multipliers based on quest type to determine the
  /// base XP reward, which increases with longer durations.
  int _calculateXpReward(QuestType type, Duration duration) {
    int baseXp = 50;
    switch (type) {
      case QuestType.distance:
        baseXp += duration.inMinutes * 5;
        break;
      case QuestType.strength:
        baseXp += duration.inMinutes * 3;
        break;
      case QuestType.mentalHealth:
        baseXp += duration.inMinutes * 2;
        break;
      case QuestType.custom:
        baseXp += duration.inMinutes * 2;
        break;
    }
    return baseXp;
  }

  /// Returns appropriate icon for the given quest type
  /// 
  /// Used to visually represent the quest type in the UI.
  IconData _getIconForType(QuestType type) {
    switch (type) {
      case QuestType.distance:
        return Icons.directions_run;
      case QuestType.strength:
        return Icons.fitness_center;
      case QuestType.mentalHealth:
        return Icons.psychology;
      case QuestType.custom:
        return Icons.star;
    }
  }
}

/// Suggested Extensions for Future Development
/// 
/// 1. Advanced Quest Parameters:
///    - Add difficulty level selection (easy/medium/hard)
///    - Implement XP multiplier based on difficulty
///    - Add optional frequency parameter (daily/weekly quests)
///    - Support recurring quests with specified intervals
/// 
/// 2. Enhanced Validation:
///    - Add form validation for required fields
///    - Implement minimum/maximum constraints for time/distance
///    - Add error messages for invalid inputs
///    - Validate that distance is provided for distance-based quests
/// 
/// 3. Visual Enhancements:
///    - Add quest type-specific color coding
///    - Implement real-time XP reward preview
///    - Add icon selection option for custom quests
///    - Include quest preview panel with formatted display
/// 
/// 4. Community Integration:
///    - Add option to make quests public/private
///    - Implement sharing options for created quests
///    - Add tags/categories for better discoverability
///    - Support collaborative quest creation
/// 
/// 5. Accessibility Improvements:
///    - Add screen reader support for form elements
///    - Implement color contrast checks
///    - Add keyboard navigation support
///    - Include input labels for assistive technologies
/// 
/// 6. Performance & Reliability:
///    - Add loading indicator during quest creation
///    - Implement undo functionality for accidental deletions
///    - Add confirmation dialog before creating quest
///    - Implement data persistence for draft quests
/// 