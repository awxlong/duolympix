import 'package:stop_watch_timer/stop_watch_timer.dart';

class TimerService {
  final StopWatchTimer _timer = StopWatchTimer();

  Stream<int> get rawTime => _timer.rawTime;
  
  void start() => _timer.onStartTimer();
  void stop() => _timer.onStopTimer();
  void dispose() => _timer.dispose();
}