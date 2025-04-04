import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;

  const TimerDisplay({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat('mm:ss').format(
        DateTime(0, 0, 0, 0, 0, duration.inSeconds),
      ),
      style: Theme.of(context).textTheme.headlineMedium, // Correct placement of 'style'
    );
  }
}