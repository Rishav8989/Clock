import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  _StopwatchTabState createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  final _stopwatch = Stopwatch();
  String _elapsedTime = '00:00:00.000';
  Timer? _timer;
  final List<String> _laps = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 10), _updateElapsedTime);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsedTime(Timer timer) {
    if (_stopwatch.isRunning && mounted) {
      setState(() {
        _elapsedTime = _formatElapsedTime(_stopwatch.elapsed);
      });
    }
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    final String milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return "$hours:$minutes:$seconds.$milliseconds";
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
    });
    _stopwatch.start();
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
    });
    _stopwatch.stop();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {
      _elapsedTime = '00:00:00.000';
      _laps.clear();
      _isRunning = false;
    });
  }

  void _recordLap() {
    setState(() {
      _laps.insert(0, _formatElapsedTime(_stopwatch.elapsed));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Stopwatch',
            style: TextStyle(fontSize: 24, color: Colors.white70),
          ),
          Text(
            _elapsedTime,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _isRunning ? null : _startStopwatch,
                child: const Text('Start'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _isRunning ? _stopStopwatch : null,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetStopwatch,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isRunning ? _recordLap : null,
            child: const Text('Lap'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Lap ${(_laps.length - index)}: ${_laps[index]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}