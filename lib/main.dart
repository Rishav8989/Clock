import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // AMOLED pitch black
        primaryColor: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
      home: ClockHomePage(),
    );
  }
}

class ClockHomePage extends StatefulWidget {
  @override
  _ClockHomePageState createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Clock App')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stop),
            label: 'Stopwatch',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          ClockTab(),
          TimerTab(),
          StopwatchTab(),
        ],
      ),
    );
  }
}

// Clock Tab
class ClockTab extends StatefulWidget {
  @override
  _ClockTabState createState() => _ClockTabState();
}

class _ClockTabState extends State<ClockTab> {
  String _timeString = ''; // Initialize to an empty string
  Timer? _timer; // Make the timer nullable

  @override
  void initState() {
    super.initState();
    _getTime(); // Get initial time
    _timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer in dispose
    super.dispose();
  }

  void _getTime() {
    if (mounted) {
      final DateTime now = DateTime.now();
      setState(() {
        _timeString = _formatTime(now);
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Current Time',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          Text(
            _timeString,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Timer Tab
class TimerTab extends StatefulWidget {
  @override
  _TimerTabState createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  String _displayTime = '00:00:00';
  bool _timeIsSet = false;

  @override
  void initState() {
    super.initState();
    _updateDisplayTime();
  }

  void _startTimer() {
    _calculateTotalSeconds();
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        if (mounted) {
          setState(() {
            _totalSeconds--;
            _updateFromTotalSeconds();
            _updateDisplayTime();
          });
        }
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
      _totalSeconds = 0;
      _updateDisplayTime();
      _timeIsSet = false; // Reset timeIsSet when resetting
    });
  }

  void _updateDisplayTime() {
    _displayTime =
        "${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}";
  }

  void _calculateTotalSeconds() {
    _totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;
  }

  void _updateFromTotalSeconds() {
    _hours = _totalSeconds ~/ 3600;
    _minutes = (_totalSeconds % 3600) ~/ 60;
    _seconds = _totalSeconds % 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Remove leading zeros when tapped
              setState(() {
                _hours = int.tryParse(_hours.toString()) ?? 0;
                _minutes = int.tryParse(_minutes.toString()) ?? 0;
                _seconds = int.tryParse(_seconds.toString()) ?? 0;
                _updateDisplayTime();
              });
            },
            child: Text(
              'Timer: $_displayTime',
              style: const TextStyle(fontSize: 30),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeInput('Hours', _hours, (value) {
                setState(() {
                  _hours = value;
                  _timeIsSet = true; // Time is set when any input changes
                });
              }),
              _buildTimeInput('Minutes', _minutes, (value) {
                setState(() {
                  _minutes = value;
                  _timeIsSet = true;
                });
              }),
              _buildTimeInput('Seconds', _seconds, (value) {
                setState(() {
                  _seconds = value;
                  _timeIsSet = true;
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          if (_timeIsSet) // Show Start button only if time is set
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  child: const Text('Stop'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      children: [
        Text(label),
        SizedBox(
          width: 70,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            controller: TextEditingController(text: value.toString()),
            onChanged: (text) {
              int newValue = int.tryParse(text) ?? 0;
              onChanged(newValue);
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ],
          ),
        ),
      ],
    );
  }
}

// Stopwatch Tab
class StopwatchTab extends StatefulWidget {
  @override
  _StopwatchTabState createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  final _stopwatch = Stopwatch();
  String _elapsedTime = '00:00:00.000';
  Timer? _timer;
  List<String> _laps = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(milliseconds: 10), _updateElapsedTime);
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
    final String milliseconds =
        (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
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
