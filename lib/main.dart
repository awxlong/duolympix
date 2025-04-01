import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:async'; // for StreamSubscription

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solo Leveling Quest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const QuestScreen(),
    );
  }
}

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  _QuestScreenState createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final double _targetDistance = 1.0; // 1 mile
  double _distanceCovered = 0.0;
  Position? _startPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isRunning = false;
  bool _questCompleted = false;
  bool _questFailed = false;

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startQuest() async {
    // Request location permissions
    final status = await Geolocator.checkPermission();
    if (status != LocationPermission.always && 
        status != LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
    }

    // Get initial position
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _startPosition = position;
      _isRunning = true;
      _questCompleted = false;
      _questFailed = false;
      _distanceCovered = 0.0;
    });

    // Start tracking position
    _positionStream = Geolocator.getPositionStream().listen((position) {
      if (_startPosition != null) {
        final distanceInMeters = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _distanceCovered = distanceInMeters * 0.000621371; // Convert to miles
        });
      }
    });

    // Start timer
    _stopWatchTimer.onStartTimer();
  }

  void _endQuest() {
    _positionStream?.cancel();
    _stopWatchTimer.onStopTimer();
    final timeElapsed = _stopWatchTimer.rawTime.value;

    setState(() {
      _isRunning = false;
      // Check both conditions
      _questCompleted = _distanceCovered >= _targetDistance && 
                       timeElapsed < 600000; // 10 minutes
      _questFailed = !_questCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quest'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Current Quest:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.directions_run, size: 50, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      "Run ${_targetDistance} mile${_targetDistance > 1 ? 's' : ''} "
                      "in under 10 minutes!",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProgressIndicator('Distance', 
                          '${_distanceCovered.toStringAsFixed(2)}/${_targetDistance} mi'),
                        const SizedBox(width: 20),
                        _buildProgressIndicator('Time', _formatTime()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              LinearProgressIndicator(
                value: _distanceCovered / _targetDistance,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 15,
              ),
              const SizedBox(height: 20),
              // ... (keep the rest of the UI elements from previous version)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatTime() {
    final value = _stopWatchTimer.rawTime.value;
    final seconds = (value ~/ 1000) % 60;
    final minutes = (value ~/ (1000 * 60)) % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}