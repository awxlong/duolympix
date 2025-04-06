import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class TimerDisplay extends StatelessWidget {
  final Duration duration;
  final Duration? targetDuration;

  const TimerDisplay({
    super.key,
    required this.duration,
    this.targetDuration,
  });

  @override
  Widget build(BuildContext context) {
    final remainingTime = targetDuration != null 
        ? targetDuration! - duration 
        : Duration.zero;

    return Column(
      children: [
        Text(
          'Elapsed: ${_formatDuration(duration)}',
          style: const TextStyle(fontSize: 20),
        ),
        if (targetDuration != null)
          Text(
            'Remaining: ${_formatDuration(remainingTime)}',
            style: TextStyle(
              fontSize: 16,
              color: remainingTime.isNegative ? Colors.red : Colors.grey,
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration d) => 
      '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
}