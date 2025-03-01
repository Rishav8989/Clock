import 'package:Clock/data/timezones.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockTab extends StatefulWidget {
  const ClockTab({super.key});

  @override
  _ClockTabState createState() => _ClockTabState();
}

class _ClockTabState extends State<ClockTab> {
  final Map<String, String> _timeStrings = {};
  Timer? _timer;
  List<String> _timeZones = ['Asia/Kolkata']; // Default to India time
  final List<String> _allTimezones = allTimezonesList;
  final List<String> _filteredTimezones = [];
  String? _selectedTimezone;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _getTimes();
    _loadTimeZones();
    print("All timezones count (from file): ${_allTimezones.length}");
    _filteredTimezones.addAll(_allTimezones);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTimes());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTimeZones() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTimeZones = prefs.getStringList('timeZones');
    if (savedTimeZones != null && savedTimeZones.isNotEmpty) {
      setState(() {
        _timeZones = savedTimeZones;
      });
    }
  }

  Future<void> _saveTimeZones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('timeZones', _timeZones);
  }

  void _getTimes() {
    if (mounted) {
      setState(() {
        _timeStrings.clear();
        for (var timeZoneName in _timeZones) {
          try {
            final location = tz.getLocation(timeZoneName);
            final now = tz.TZDateTime.now(location);
            _timeStrings[timeZoneName] = _formatTime(now);
          } catch (e) {
            _timeStrings[timeZoneName] = 'Invalid Timezone';
            print('Error getting time for $timeZoneName: $e');
          }
        }
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm:ss');
    return formatter.format(dateTime);
  }

  String _getCityNameFromTimezone(String timezoneName) {
    return timezoneName.split('/').last.replaceAll('_', ' ');
  }

  void _addTimezone() {
    _selectedTimezone = null;
    _searchController.clear();
    _filteredTimezones.clear();
    _filteredTimezones.addAll(_allTimezones);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text('Add Timezone'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Search Timezone'),
                    onChanged: (value) {
                      _filterTimezones(value, dialogSetState);
                    },
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredTimezones.length,
                      itemBuilder: (context, index) {
                        final timezoneName = _filteredTimezones[index];
                        return RadioListTile<String>(
                          title: Text(timezoneName),
                          value: timezoneName,
                          groupValue: _selectedTimezone,
                          onChanged: (String? value) {
                            dialogSetState(() {
                              _selectedTimezone = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (_selectedTimezone != null) {
                      setState(() {
                        _timeZones.add(_selectedTimezone!);
                      });
                      _saveTimeZones();
                      _getTimes();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterTimezones(String query, StateSetter dialogSetState) {
    dialogSetState(() {
      if (query.isEmpty) {
        _filteredTimezones.clear();
        _filteredTimezones.addAll(_allTimezones);
      } else {
        _filteredTimezones.clear();
        _filteredTimezones.addAll(
          _allTimezones.where((timezone) => timezone.toLowerCase().contains(query.toLowerCase())),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Keep Center widget here to center horizontally and vertically
      child: SingleChildScrollView(
        child: SizedBox( // Add SizedBox to control width for centering
          width: 400, // Adjust width as needed for centering
          child: Column( // Your main content Column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'India (Kolkata)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                _timeStrings['Asia/Kolkata'] ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTimezone,
                child: const Text('Add Timezone'),
              ),
              const SizedBox(height: 20),
              if (_timeZones.length > 1)
                const Text(
                  'Other Timezones',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              Column(
                children: _timeZones.skip(1).map((timeZoneName) {
                  final cityName = _getCityNameFromTimezone(timeZoneName);
                  return Dismissible(
                    key: Key(timeZoneName),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        _timeZones.remove(timeZoneName);
                      });
                      _saveTimeZones();
                      _getTimes();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$cityName Timezone removed')),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(
                        title: Text(
                          cityName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _timeStrings[timeZoneName] ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _timeZones.remove(timeZoneName);
                            });
                            _saveTimeZones();
                            _getTimes();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$cityName Timezone removed')),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}