import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/features/quests/data/models/quest_model.dart';
import 'package:solo_leveling/features/quests/provider/quest_provider.dart';

class QuestDesignScreen extends StatefulWidget {
  const QuestDesignScreen({super.key});

  @override
  State<QuestDesignScreen> createState() => _QuestDesignScreenState();
}

class _QuestDesignScreenState extends State<QuestDesignScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  QuestType _selectedType = QuestType.distance;
  final TextEditingController _timeValueController = TextEditingController(text: '5');
  bool _isUpperBound = true;
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quest Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Quest Description'),
            ),
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
            if (_selectedType == QuestType.distance)
              TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Miles to run'),
              ),
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
            TextField(
              controller: _timeValueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Time in minutes'),
            ),
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
