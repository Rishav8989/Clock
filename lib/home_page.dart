// clock_home_page.dart (or wherever your ClockHomePage is)
import 'package:flutter/material.dart';
import 'clock_tab.dart';
import 'timer_tab.dart';
import 'stopwatch_tab.dart';

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

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
        title: const Text('Clock App'),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
