import 'package:flutter/material.dart';

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
          'Remaining: ${_formatDuration(remainingTime)}',
          style: const TextStyle(fontSize: 20),
        ),
        
      ],
    );
  }

  String _formatDuration(Duration d) => 
      '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
}