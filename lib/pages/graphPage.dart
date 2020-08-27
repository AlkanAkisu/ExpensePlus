import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracker_but_fast/expenses_store.dart';
import 'package:tracker_but_fast/models/tag.dart';

class GraphPage extends StatefulWidget {
  GraphPage({Key key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

enum ViewType { Day, Week, Month }

class _GraphPageState extends State<GraphPage>
    with SingleTickerProviderStateMixin {
  CalendarController calendarController = new CalendarController();
  final store = MobxStore.st;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    var today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    print(store.graphSelectedDate);
    store.updateGraphSelectedDate(store.graphSelectedDate ?? today);

    _controller = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xfff9f9f9),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              calendar(),
              graph(),
            ],
          ),
        ),
      ),
    );
  }

// #region CALENDAR

  Widget calendar() {
    return Observer(builder: (_) {
      store.selectedDate; //for update
      return TableCalendar(
        calendarController: calendarController,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 55,
        initialSelectedDay: store.graphSelectedDate ?? DateTime.now(),
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
        ),
        onDaySelected: (day, events) {
          store.updateGraphSelectedDate(day);
          store.updateSelectedDate(day);
        },
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, events) {
            return calendarTile(context, date, events,
                textColor: Colors.white, backgroundColor: Colors.blue[200]);
          },
          weekendDayBuilder: (context, date, events) {
            return calendarTile(
              context,
              date,
              events,
              textColor: Colors.red,
            );
          },
          outsideDayBuilder: (context, date, events) {
            return calendarTile(
              context,
              date,
              events,
              textColor: date.weekday > 5 ? Colors.red : null,
              dateWeight: FontWeight.w200,
              expenseWeight: FontWeight.w100,
            );
          },
          outsideWeekendDayBuilder: (context, date, events) {
            return calendarTile(
              context,
              date,
              events,
              textColor: Colors.red,
              dateWeight: FontWeight.w200,
              expenseWeight: FontWeight.w100,
            );
          },
          dayBuilder: (context, date, events) {
            return calendarTile(
              context,
              date,
              events,
            );
          },
        ),
        calendarStyle: CalendarStyle(),
      );
    });
  }

  Widget calendarTile(
    BuildContext context,
    DateTime date,
    List<dynamic> events, {
    Color textColor,
    Color backgroundColor,
    FontWeight dateWeight,
    FontWeight expenseWeight,
  }) {
    String expenseText = MobxStore.st.getSelectedDateTotalPrice(date) == 0
        ? ''
        : MobxStore.st.getSelectedDateTotalPrice(date).toString();

    return Container(
      margin: EdgeInsets.all(0.3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontWeight: dateWeight ?? FontWeight.w500,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
          Text(
            expenseText,
            style: TextStyle(
              fontWeight: expenseWeight ?? FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

// #endregion CALENDAR

// #region Graph

  Widget graph() {
    return Observer(builder: (_) {
      store.graphSelectedDateExpenses;
      store.graphSelectedDate;
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 7,
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[400],
              ),
              child: TabBar(
                controller: _controller,
                tabs: [
                  Tab(
                    icon: Icon(Icons.view_day),
                    text: 'Day',
                  ),
                  Tab(
                    icon: Icon(Icons.view_week),
                    text: 'Week',
                  ),
                  Tab(
                    icon: Icon(Icons.view_comfy),
                    text: 'Month',
                  ),
                ],
              ),
            ),
            Container(
              height: 400,
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  tabViewElement(
                    ViewType.Day,
                  ),
                  tabViewElement(
                    ViewType.Week,
                  ),
                  tabViewElement(
                    ViewType.Month,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget tabViewElement(
    ViewType type,
  ) {
    var tags = store.getTagTotalGraph(store.graphSelectedDateExpenses[type]);
    var entries = tags.entries.toList();
    var percent;
    entries.sort((a, b) => -a.value.compareTo(b.value));
    double totalExpenseOfTags = entries.fold(
      0,
      (prev, el) {
        return el.value + prev;
      },
    );

    bool limitextended = totalExpenseOfTags > store.limitMap[type];
    Color color = limitextended ? Colors.red[700] : Colors.black;
    FontWeight fontWeight = limitextended ? FontWeight.w700 : FontWeight.w500;
    double fontSize = limitextended ? 19 : 17;

    return SingleChildScrollView(
      child: entries.isEmpty
          ? Container()
          : Column(
              children: <Widget>[
                Container(
                  //total expense
                  height: 50,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 2,
                      color: color,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Total / Limit : $totalExpenseOfTags / ${store.limitMap[type]}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        color: color,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                ...entries.map((entry) {
                  var tag = entry.key;
                  var expenseOfTag = entry.value;
                  percent = (expenseOfTag / totalExpenseOfTags) * 100;
                  return graphTile(tag, expenseOfTag, percent);
                }).toList(),
                PieChart(
                  dataMap: entries.fold(
                    {},
                    (prev, element) {
                      return {
                        ...prev,
                        element.key.name: element.value,
                      };
                    },
                  ),
                  colorList: entries.fold(
                    [],
                    (prev, element) {
                      return [
                        ...prev,
                        element.key.color,
                      ];
                    },
                  ),
                )
              ],
            ),
    );
  }

  Widget graphTile(Tag tag, double expenseOfTag, double percent) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                decoration: BoxDecoration(
                  color: tag.color,
                ),
              ),
              SizedBox(width: 6),
              Text(
                tag.name.toUpperCase(),
                style: TextStyle(
                  letterSpacing: 0.75,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Text(
            '${percent.toStringAsFixed(2)}%',
            style: TextStyle(
              letterSpacing: 0.75,
              fontSize: 15,
            ),
          ),
          Text(
            expenseOfTag.toString(),
            style: TextStyle(
              letterSpacing: 0.75,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

// #endregion Graph

}
