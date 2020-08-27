import 'package:flutter/material.dart';
import 'package:tracker_but_fast/pages/graphPage.dart';
import 'package:tracker_but_fast/pages/settingsPage.dart';
import 'package:tracker_but_fast/pages/tagsPage.dart';
import 'package:tracker_but_fast/pages/trackPage.dart';

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
    Destination('Tags', Icons.bookmark_border, TagsPage()),
  ];
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Tracker But Fast',
        home: SafeArea(
          child: Scaffold(
            appBar: appBar(context),
            bottomNavigationBar: SizedBox(
              height: 60,
              child: bottomNavigationBar(),
            ),
            body: allDestinations[_currentIndex].widget,
          ),
        ));
  }

  AppBar appBar(BuildContext bc) {
    return AppBar(
      backgroundColor: Colors.grey[700],
      title: Text(
        'Tracker But Fast',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            navigatorKey.currentState.push(
              MaterialPageRoute(
                builder: (_) => SettingsPage(),
              ),
            );
          },
        ),
      ],
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
