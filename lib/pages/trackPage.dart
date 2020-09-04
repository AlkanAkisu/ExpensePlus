import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:expensePlus/database/expense_provider.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/models/expense.dart';
import 'package:expensePlus/pages/graphPage.dart';
import 'package:expensePlus/utilities/regex.dart';
import 'package:expensePlus/widgets/expenseTile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:expensePlus/models/tag.dart';

class TrackPage extends StatefulWidget {
  @override
  _TrackPageState createState() => _TrackPageState();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
}

class _TrackPageState extends State<TrackPage> {
  Map<int, double> opacity = new Map();
  TextEditingController controller;

  var focusNode = new FocusNode();
  GlobalKey<AnimatedListState> listKey;
  final store = MobxStore.st;

  DateTime selectedDate;
  double calendarHeight;
  CalendarController _calendarController;
  List<Expense> selectedDateExpenses;

  Expense thumbnailExpense;
  bool showThumbnail = false, isKeyboardActive = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    store.editing = <Expense>{};
    this.listKey = widget.listKey;
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    if (store.selectedDate == null) store.updateSelectedDate(selectedDate);

    _calendarController = CalendarController();
    calendarHeight = 0;

    KeyboardVisibility.onChange.listen((bool visible) {
      isKeyboardActive = visible;

      if (this.mounted && isKeyboardActive && calendarHeight > 0)
        setState(() {
          calendarHeight = 0;
        });
      if (this.mounted && !isKeyboardActive && store.editing.isNotEmpty)
        setState(() {
          store.editing = {};
          controller.text = '';
        });
      if (this.mounted && !isKeyboardActive && showThumbnail)
        setState(() {
          //TODO text memory do controller.text = oldtext when click back
          showThumbnail = false;
          store.thumbnailExpense = null;
          FocusScope.of(focusNode.context).unfocus();
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xfff9f9f9),
          child: Observer(builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                calendarShowSection(),
                calendar(),
                store.selectedDateExpenses.isNotEmpty
                    ? Text(
                        'Hint: Swipe Right To Edit, Left To Delete And Click A Tag For More Info',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w200),
                      )
                    : Container(),
                expensesListWidget(),
                totalPriceWidget(),
                thumbnailWidget(),
                addPriceWidget(),
              ],
            );
          }),
        ),
      ),
    );
  }

  //---------------CALENDAR---------------
  // #region

  Widget calendar() {
    return Container(
      height: calendarHeight,
      child: SingleChildScrollView(
        child: Observer(
          builder: (_) {
            return TableCalendar(
              calendarController: _calendarController,
              startingDayOfWeek: StartingDayOfWeek.monday,
              initialSelectedDay: store.selectedDate,
              calendarStyle: CalendarStyle(),
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
              rowHeight: 35,
              onDaySelected: (day, events) {
                // focusNode.unfocus();;
                selectedDate = new DateTime(day.year, day.month, day.day);
                store.updateSelectedDate(selectedDate);
                store.updateGraphSelectedDate(selectedDate);
                calendarHeight = 0;
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }

  Widget calendarShowSection() {
    return Observer(builder: (_) {
      store.selectedDate;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue[700],
            ),
            onPressed: calendarHeight != 0
                ? null
                : () {
                    var newDate = store.selectedDate.subtract(
                      Duration(
                        days: 1,
                      ),
                    );
                    store.updateSelectedDate(newDate);
                    store.updateGraphSelectedDate(newDate);
                  },
          ),
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(4.0),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  // color: Colors.grey[400],
                  border: Border.all(
                    color: Colors.blue[700],
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 60,
                child: GestureDetector(
                  onTap: calendarButtonPressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Observer(builder: (_) {
                          var date = store.selectedDate;
                          return Container(
                            padding: const EdgeInsets.all(4.0),
                            margin: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          );
                        }),
                      ),
                      IconButton(
                        icon: Icon(
                          calendarHeight == 0
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                          color: Colors.blue[700],
                        ),
                        onPressed: () async => calendarButtonPressed(),
                      )
                    ],
                  ),
                )),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.blue[700],
            ),
            onPressed: calendarHeight != 0
                ? null
                : () {
                    var newDate = store.selectedDate.add(
                      Duration(
                        days: 1,
                      ),
                    );
                    store.updateSelectedDate(newDate);
                    store.updateGraphSelectedDate(newDate);
                  },
          ),
        ],
      );
    });
  }

  // #endregion

  //---------------EXPENSES LIST WIDGET---------------
  // #region

  Widget expensesListWidget() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: listViewExpenses(),
    ));
  }

  Widget listViewExpenses() {
    return Observer(
      builder: (_) {
        store.selectedDate;
        store.expenses;

        List<Expense> selectedDateExpenses = store.selectedDateExpenses;

        return new AnimatedList(
          key: listKey,
          initialItemCount:
              100, // needs to be higher because we change the item count
          itemBuilder: (bc, i, anim) {
            if (selectedDateExpenses.length <= i) return null;

            Expense expense = selectedDateExpenses[i];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: Slidable(
                actionPane: SlidableStrechActionPane(),
                direction: Axis.horizontal,
                actions: <Widget>[
                  IconSlideAction(
                    caption: 'Edit',
                    color: Colors.blue,
                    icon: Icons.edit,
                    onTap: () => editButtonPressed(expense.id),
                  ),
                ],
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => deleteButtonPressed(expense.id),
                  ),
                ],
                child: FadeTransition(
                  opacity: anim,
                  child: ExpenseTile(
                    expense: expense,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget thumbnailWidget() {
    return Opacity(
      opacity: 0.5,
      child: Observer(builder: (_) {
        store.thumbnailExpense;
        store.editing;
        Expense expenseToShow = store.thumbnailExpense;
        if (showThumbnail && store.thumbnailExpense == null)
          expenseToShow = Expense(
            tags: [Tag.otherTag],
            name: 'other',
            prices: [0.0],
          );

        if (showThumbnail || store.editing.isNotEmpty) {
          return ExpenseTile(
            expense: store.thumbnailExpense,
          );
        } else {
          return Container();
        }
      }),
    );
  }

  Widget totalPriceWidget() {
    return Observer(builder: (_) {
      store.selectedDate;
      store.limitMap;
      store.editing;

      var totalPrice = store.getSelectedDateTotalPrice();

      //text styles
      bool limitextended;
      bool isUseLimit =
          store.limitMap[ViewType.Day] != null && store.isUseLimit;

      if (isUseLimit)
        limitextended = totalPrice > store.limitMap[ViewType.Day];
      else
        limitextended = false;
      Color color = limitextended ? Colors.red[700] : Colors.blue[700];
      FontWeight fontWeight = limitextended ? FontWeight.w700 : FontWeight.w500;
      double fontSize = limitextended ? 21 : 19;

      return Container(
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        height: !showThumbnail ? 60 : 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              isUseLimit
                  ? 'Total / Limit : $totalPrice / ${store.limitMap[ViewType.Day]}'
                  : 'Total Expense : $totalPrice ',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: 1.2,
                color: color,
              ),
            ),
          ],
        ),
      );
    });
  }

  // #endregion
  //---------------ADD PRICE TEXT FIELD---------------

  Widget addPriceWidget() {
    controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 80,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: (text) async {
                store.setThumbnailExpense(
                  await Regex.doRegex(
                    text,
                    store.selectedDate,
                    false,
                  ),
                );
              },
              onTap: () {
                if (store.editing.isNotEmpty) return;

                if (calendarHeight == null)
                  setState(() {
                    calendarHeight = 0;
                  });

                if (!showThumbnail) {
                  showThumbnail = true;

                  setState(() {});
                }
              },
              focusNode: focusNode,
              textInputAction: TextInputAction.send,
              controller: controller,
              maxLines: null,
              minLines: null,
              onSubmitted: (value) => textFieldSubmitted(controller),
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.6,
              ),
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  hintText: 'Enter a expense',
                  helperText:
                      ' . prefix to add tag (.travel .food) or shorten it (.t .f)'),
            ),
          ),
          editCancelButton(),
        ],
      ),
    );
  }

  Widget editCancelButton() {
    return Observer(builder: (_) {
      const double kSize = 40;
      return Container(
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 7),
        width: store.editing.isNotEmpty ? null : 0,
        child: IconButton(
          onPressed: editCancelPressed,
          constraints: BoxConstraints(
            maxHeight: kSize,
            maxWidth: kSize,
          ),
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          highlightColor: Colors.red,
        ),
      );
    });
  }
  //
  //--------------LOGIC--------------

  // #region Logic

  textFieldSubmitted(TextEditingController controller) async {
    Expense regexExpense = await Regex.doRegex(
      controller.text,
      store.selectedDate,
      true,
    );
    print('regexExpense:\t $regexExpense');
    showThumbnail = false;
    store.thumbnailExpense = null;

    controller.text = '';

    if (store.editing.isNotEmpty) {
      //EDITING PART

      Expense expenseToAdd = regexExpense;
      expenseToAdd.id = store.editing.first.id;

      store.updateExpense(expenseToAdd, setDatabase: true);
      store.editing = {};
    } else {
      //ADDING PART

      store.addExpense(regexExpense, setDatabase: true);

      if (isSelectedDate(regexExpense))
        listKey.currentState.insertItem(store.selectedDateExpenses.length - 1);
    }
    showThumbnail = false;

    setState(() {});
  }

  deleteButtonPressed(int id) {
    Expense expense =
        store.selectedDateExpenses.firstWhere((element) => element.id == id);

    ExpenseProvider.db.delete(expense).then((value) {
      print('deleted');
    });

    AnimatedListRemovedItemBuilder builder = (context, anim) {
      return FadeTransition(
        opacity: anim,
        child: ExpenseTile(
          expense: expense,
        ),
      );
    };

    listKey.currentState.removeItem(
      store.selectedDateExpenses.indexOf(expense),
      builder,
      duration: Duration(milliseconds: 500),
    );
    store.deleteExpense(expense);
    setState(() {});
  }

  editButtonPressed(int id) {
    Expense expense = store.selectedDateExpenses.firstWhere(
      (element) => element.id == id,
    );

    store.editing = {expense};
    focusNode.requestFocus();

    //to set state of total expense widget
    store.selectedDate = DateTime.parse(store.selectedDate.toIso8601String());

    controller.text = expense.text;

    showThumbnail = true;

    store.thumbnailExpense = expense;
  }

  Future calendarButtonPressed() async {
    if (isKeyboardActive) {
      focusNode.unfocus();
      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 200));
        return isKeyboardActive;
      });
    }

    if (calendarHeight != null)
      calendarHeight = null;
    else
      calendarHeight = 0;
    setState(() {});
  }

  bool isSelectedDate(Expense exp) {
    return exp.date.year == store.selectedDate.year &&
        exp.date.month == store.selectedDate.month &&
        exp.date.day == store.selectedDate.day;
  }

  editCancelPressed() {
    store.editing = {};
    focusNode.unfocus();
    controller.text = '';
  }
// #endregion

}
