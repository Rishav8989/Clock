import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

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
      _timeIsSet = false;
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
                  _timeIsSet = true;
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
          if (_timeIsSet)
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
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }
}