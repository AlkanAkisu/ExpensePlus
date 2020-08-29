import 'package:flutter/material.dart';

import 'database/limit_provider.dart';
import 'database/tag_provider.dart';
import 'expenses_store.dart';
import 'pages/graphPage.dart';
import 'pages/settingsPage.dart';
import 'pages/tagsPage.dart';
import 'pages/trackPage.dart';

void main() async {
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
  bool initDone = false;

  @override
  void initState() {
    super.initState();
    init().then((value) => initDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Tracker But Fast',
      home: SafeArea(
        //FUTUR BUILDER KULLANMA
        child: Builder(
          builder: (context) {
            if (initDone)
              return Scaffold(
                appBar: appBar(context),
                bottomNavigationBar: SizedBox(
                  height: 60,
                  child: bottomNavigationBar(),
                ),
                body: allDestinations[_currentIndex].widget,
              );

            return Scaffold(
              body: splashScreen(),
            );
          },
        ),
      ),
    );
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

  Widget splashScreen() {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[500],
          gradient: RadialGradient(
            colors: [
              Colors.blue[500],
              Colors.blue[500],
              Colors.blue[700],
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.attach_money,
                size: 64,
                color: Colors.white,
              ),
              Text(
                'TRACKER\nBUT FAST',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    if (initDone) return [];

    final futures = await Future.wait([
      TagProvider.db.getAllTags(true),
      LimitProvider.db.getLimit(),
      LimitProvider.db.getIsAutomatic(),
      LimitProvider.db.getUseLimit(),
    ]);

    print('init');
    final store = MobxStore.st;

    if (store.limitMap.isEmpty) store.limitMap = futures[1];

    if (store.isAutomatic == null) store.isAutomatic = futures[2];

    if (store.isUseLimit == null) store.isUseLimit = futures[3];

    initDone = true;
    setState(() {});
  }
}
