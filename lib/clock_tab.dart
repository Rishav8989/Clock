import 'package:flutter/material.dart';
import 'dart:async';

class ClockTab extends StatefulWidget {
  const ClockTab({super.key});

  @override
  _ClockTabState createState() => _ClockTabState();
}

class _ClockTabState extends State<ClockTab> {
  String _timeString = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
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