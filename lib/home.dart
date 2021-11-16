import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/controller.dart';
import 'package:marklin_bluetooth/lap_counter.dart';
import 'package:marklin_bluetooth/race_browser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _pages = [
    const ControllerScreen(),
    const LapCounterScreen(),
    const RaceBrowserScreen(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: "Controller"),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Race"),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: "Browser")
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}