import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/models/tag.dart';
import 'package:expensePlus/pages/tagDetailPage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

enum ViewType { Day, Week, Month }

class GraphPage extends HookWidget {
  CalendarController calendarController = new CalendarController();
  final store = MobxStore.st;
  TabController _controller;

  // void initState() {}

  @override
  Widget build(BuildContext context) {
    _controller = useTabController(initialLength: 3);

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
      store.tags;
      store.expenses;
      return TableCalendar(
        calendarController: calendarController,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 55,
        initialSelectedDay: store.graphSelectedDate ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            ),
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
        ),
        onDaySelected: (day, events) {
          store.updateGraphSelectedDate(day);
          store.updateSelectedDate(day);
          _controller.animateTo(0);
        },
        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, events) {
            return calendarTile(context, date, events,
                textColor: Colors.white, backgroundColor: Colors.blue[200]);
          },
          todayDayBuilder: (context, date, events) {
            return calendarTile(context, date, events,
                textColor: Colors.black, backgroundColor: Colors.blue[50]);
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

    bool limitextended = false;
    bool isUseLimit = store.limitMap[ViewType.Day] != null && store.isUseLimit;
    if (isUseLimit)
      limitextended = MobxStore.st.getSelectedDateTotalPrice(date) >
          store.limitMap[ViewType.Day];

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
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: TextStyle(
              fontWeight: !limitextended
                  ? expenseWeight ?? FontWeight.w300
                  : FontWeight.w400,
              fontSize: !limitextended ? 12 : 13,
              color: !limitextended ? Colors.black : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

// #endregion

// #region Graph

  Widget graph() {
    return Observer(builder: (_) {
      store.graphSelectedDateExpenses;
      store.graphSelectedDate;
      store.tags;
      store.expenses;

      print('All expenses GRAPH=>${store.expenses}');

      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 7,
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue[700],
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _controller,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue[100],
                ),
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.view_day,
                      color: Colors.blue[700],
                    ),
                    child: Text(
                      'Day',
                      style: TextStyle(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.view_week,
                      color: Colors.blue[700],
                    ),
                    child: Text(
                      'Week',
                      style: TextStyle(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.view_comfy,
                      color: Colors.blue[700],
                    ),
                    child: Text(
                      'Month',
                      style: TextStyle(
                        color: Colors.blue[700],
                      ),
                    ),
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

  Widget tabViewElement(ViewType type) {
    Map<Tag, double> tags =
        store.getTagTotalGraph(store.graphSelectedDateExpenses[type]);

    var entries = tags.entries.toList();
    var percent;
    entries.sort((a, b) => -a.value.compareTo(b.value));
    double totalExpenseOfTags = store.getTotalExpenseByView(type);

    bool limitextended = false;
    bool isUseLimit = store.limitMap[type] != null && store.isUseLimit;
    if (isUseLimit) limitextended = totalExpenseOfTags > store.limitMap[type];

    Color color = limitextended ? Colors.red[700] : Colors.black;
    FontWeight fontWeight = limitextended ? FontWeight.w700 : FontWeight.w500;
    double fontSize = limitextended ? 19 : 17;

    return SingleChildScrollView(
      child: entries.isEmpty
          ? Container(
              height: 100,
              child: Center(
                child: Text(
                  'No Expense Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            )
          : Container(
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hint: Click A Tag For More Info',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                  ),
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
                        isUseLimit
                            ? 'Total / Limit : $totalExpenseOfTags / ${store.limitMap[type]}'
                            : 'Total Expense: $totalExpenseOfTags ',
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
                ],
              ),
            ),
    );
  }

  Widget graphTile(Tag tag, double expenseOfTag, double percent) {
    return GestureDetector(
      onTap: () => MobxStore.st.navigatorKey.currentState.push(
        MaterialPageRoute(
          builder: (_) => TagDetailPage(tag),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        height: 70,
        child: Row(
          children: <Widget>[
            Container(
              width: 15,
              decoration: BoxDecoration(
                color: tag.color,
              ),
            ),
            SizedBox(width: 8),
            SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxWidth: 150),
                child: Text(
                  tag.name.toUpperCase(),
                  style: TextStyle(
                    letterSpacing: 0.75,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Spacer(),
            Container(
              constraints: BoxConstraints(minWidth: 60),
              child: Text(
                '${percent.toStringAsFixed(2)}%',
                style: TextStyle(
                  letterSpacing: 0.75,
                  fontSize: 15,
                ),
              ),
            ),
            Container(constraints: BoxConstraints(maxWidth: 50)),
            Container(
              constraints: BoxConstraints(minWidth: 60),
              child: Text(
                expenseOfTag.toString(),
                style: TextStyle(
                  letterSpacing: 0.75,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// #endregion Graph

}
