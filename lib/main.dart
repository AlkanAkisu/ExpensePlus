import 'package:expensePlus/pages/introPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:expensePlus/database/expense_provider.dart';
import 'package:expensePlus/utilities/dummy_data.dart';

import 'package:expensePlus/database/settings_provider.dart';
import 'package:expensePlus/database/tag_provider.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/pages/graphPage.dart';
import 'package:expensePlus/pages/settingsPage.dart';
import 'package:expensePlus/pages/tagsPage.dart';
import 'package:expensePlus/pages/trackPage.dart';

import 'package:time/time.dart';

void main() async {
  MobxStore.st.icon = Image(
    image: AssetImage('assets/icon/icon.png'),
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      print('loadingProgress ==> $loadingProgress');
      return Container();
    },
  );
  runApp(MyApp());
}

class BottomItems {
  const BottomItems(this.title, this.icon, this.widget);
  final String title;
  final IconData icon;
  final Widget widget;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<BottomItems> allDestinations = <BottomItems>[
    BottomItems('Graph', Icons.trending_up, GraphPage()),
    BottomItems('Add Expense', Icons.attach_money, TrackPage()),
    BottomItems('Tags', Icons.bookmark_border, TagsPage()),
  ];
  final navigatorKey = GlobalKey<NavigatorState>();
  bool initDone = false;
  bool delayDone = false;

  bool introDone = false;

  TextEditingController controller = new TextEditingController();
  var focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(200.milliseconds).then((value) => delayDone = true);
    init().then((value) => initDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Expense +',
      home: SafeArea(
        child: Observer(
          builder: (context) {
            MobxStore.st.introDone;
            MobxStore.st.firstTime;
            MobxStore.st.currentIndex;
            // return splashScreen();
            if (!initDone || !delayDone) return splashScreen();
            MobxStore.st.navigatorKey ??= navigatorKey;

            if (MobxStore.st.firstTime && !MobxStore.st.introDone)
              return IntroPage();

            return Scaffold(
              appBar: appBar(context),
              bottomNavigationBar: SizedBox(
                height: 55,
                child: bottomNavigationBar(),
              ),
              body: allDestinations[MobxStore.st.currentIndex].widget,
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
          icon: Icon(Icons.help),
          onPressed: () {
            navigatorKey.currentState.push(
              MaterialPageRoute(
                builder: (_) => IntroPage(true),
              ),
            );
          },
        ),
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
      backgroundColor: Colors.grey[700],
      currentIndex: MobxStore.st.currentIndex,
      onTap: (int index) {
        setState(() {
          MobxStore.st.currentIndex = index;
        });
      },
      items: allDestinations.map((BottomItems destination) {
        return BottomNavigationBarItem(
          icon: Icon(
            destination.icon,
            size: 20,
          ),
          title: Text(destination.title),
        );
      }).toList(),
    );
  }

  Widget splashScreen() {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xff1266D3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(flex: 273),
                Image(
                  image: AssetImage('assets/splashScreen/splashTextIcon.png'),
                  loadingBuilder:
                      (_, Widget child, ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Container(
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                Spacer(flex: 715),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    if (initDone) return;
    // await LimitProvider.db.resetFirstTime();
    final store = MobxStore.st;
    store.firstTime = await SettingsProvider.db.isFirstTime();
    if (store.firstTime) {
      print('${DummyData.tags()} ${DummyData.expenses()}');
      for (var newTag in DummyData.tags()) await TagProvider.db.addTag(newTag);
      for (var newExpense in DummyData.expenses())
        await ExpenseProvider.db.createExpense(newExpense);
    }
    final futures = await Future.wait([
      TagProvider.db.getAllTags(true),
      SettingsProvider.db.getLimit(),
      SettingsProvider.db.getIsAutomatic(),
      SettingsProvider.db.getUseLimit(),
      SettingsProvider.db.getDateStyle(),
    ]);

    if (store.limitMap.isEmpty) store.limitMap = futures[1];

    if (store.isAutomatic == null) store.isAutomatic = futures[2];

    if (store.isUseLimit == null) store.isUseLimit = futures[3];

    store.dateStyle = futures[4];

    store.updateGraphSelectedDate(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));

    initDone = true;
    setState(() {});
  }
}
