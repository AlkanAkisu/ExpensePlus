import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:expensePlus/database/expense_provider.dart';
import 'package:expensePlus/utilities/dummy_data.dart';


import 'package:expensePlus/database/limit_provider.dart';
import 'package:expensePlus/database/tag_provider.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/pages/graphPage.dart';
import 'package:expensePlus/pages/settingsPage.dart';
import 'package:expensePlus/pages/tagsPage.dart';
import 'package:expensePlus/pages/trackPage.dart';

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
      title: 'Expense Plus',
      home: SafeArea(
        child: Builder(
          builder: (context) {
            if (initDone) MobxStore.st.navigatorKey = navigatorKey;
            if (initDone)
              return Observer(builder: (_) {
                MobxStore.st.currentIndex;

                return Scaffold(
                  appBar: appBar(context),
                  bottomNavigationBar: SizedBox(
                    height: 60,
                    child: bottomNavigationBar(),
                  ),
                  body: allDestinations[MobxStore.st.currentIndex].widget,
                );
              });

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
        'Expense Plus',
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
      currentIndex: MobxStore.st.currentIndex,
      onTap: (int index) {
        setState(() {
          MobxStore.st.currentIndex = index;
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
                'EXPENSE PLUS',
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
    // await LimitProvider.db.resetFirstTime();
    bool firstTime = await LimitProvider.db.isFirstTime();
    if (firstTime) {
      print('${DummyData.tags()} ${DummyData.expenses()}');
      for (var newTag in DummyData.tags()) await TagProvider.db.addTag(newTag);
      for (var newExpense in DummyData.expenses())
        await ExpenseProvider.db.createExpense(newExpense);
    }
      final futures = await Future.wait([
        TagProvider.db.getAllTags(true),
        LimitProvider.db.getLimit(),
        LimitProvider.db.getIsAutomatic(),
        LimitProvider.db.getUseLimit(),
      ]);

      final store = MobxStore.st;

      if (store.limitMap.isEmpty) store.limitMap = futures[1];

      if (store.isAutomatic == null) store.isAutomatic = futures[2];

      if (store.isUseLimit == null) store.isUseLimit = futures[3];


    initDone = true;
    setState(() {});
  }
}
