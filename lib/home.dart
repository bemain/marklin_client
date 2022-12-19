import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/controller_screen/controller.dart';
import 'package:marklin_bluetooth/current_race_screen/current_race_screen.dart';
import 'package:marklin_bluetooth/portrait_mode_mixin.dart';
import 'package:marklin_bluetooth/race_browser_screen/race_browser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with PortraitModeMixin {
  final List<Widget> _pages = [
    const ControllerScreen(),
    const CurrentRaceScreen(),
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
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.swipe), label: "Controller"),
          NavigationDestination(icon: Icon(Icons.schedule), label: "Race"),
          NavigationDestination(icon: Icon(Icons.layers), label: "Browser")
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
