import 'package:flutter/material.dart';
import 'package:tracker_but_fast/pages/graph.dart';
import 'package:tracker_but_fast/pages/settings.dart';
import 'package:tracker_but_fast/pages/track.dart';

void main() {
  runApp(MyApp());
}

class Destination {
  const Destination(this.title, this.icon, this.widget);
  final String title;
  final IconData icon;
  final Widget widget;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 1;
  final List<Destination> allDestinations = <Destination>[
    Destination('Graph', Icons.trending_up, GraphPage()),
    Destination('Add Expense', Icons.attach_money, TrackPage()),
    Destination('Settings', Icons.settings, Settings()),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tracker But Fast',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(
          child: Scaffold(
            appBar: appBar(),
            bottomNavigationBar: SizedBox(
              height: 60,
              child: bottomNavigationBar(),
            ),
            body: allDestinations[_currentIndex].widget,
          ),
        ));
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.grey[700],
      title: Text(
        'Tracker But Fast',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  BottomNavigationBar bottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.white,
      selectedLabelStyle: TextStyle(
        color: Colors.red,
      ),
      selectedFontSize: 16,
      backgroundColor: Colors.grey[700],
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: allDestinations.map((Destination destination) {
        return BottomNavigationBarItem(
          icon: Icon(
            destination.icon,
          ),
          title: Text(
            destination.title,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      }).toList(),
    );
  }
}
