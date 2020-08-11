import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';
import 'package:tracker_but_fast/expenses_store.dart';
import 'package:tracker_but_fast/models/expense.dart';
import 'package:tracker_but_fast/utilities/dummy_data.dart';
import 'package:tracker_but_fast/utilities/regex.dart';
import 'package:tracker_but_fast/widgets/expenseTile.dart';

class TrackPage extends StatefulWidget {
  @override
  _TrackPageState createState() => _TrackPageState();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
}

class _TrackPageState extends State<TrackPage> {
  List<Expense> dummyData = DummyData.getData();
  Map<int, double> opacity = new Map();
  TextEditingController controller;
  Set<Expense> editing = <Expense>{};
  var focusNode = new FocusNode();
  GlobalKey<AnimatedListState> listKey;
  final store = MobxStore.st;
  DateTime now;
  DateTime selectedDate;
  double calendarHeight;
  CalendarController _calendarController;
  List<Expense> selectedDateExpenses;

  Expense thumbnailExpense;
  bool showThumbnail = false, isKeyboardActive = false, hideTotalPrice = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('INIT\t');
    this.listKey = widget.listKey;
    now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    store.updateSelectedDate(selectedDate);

    _calendarController = CalendarController();
    calendarHeight = 0;

    KeyboardVisibility.onChange.listen((bool visible) {
      isKeyboardActive = visible;
      print('KEYBOARD\t visible:$visible calendar:${calendarHeight > 0}');
      if (this.mounted && visible && calendarHeight > 0)
        setState(() {
          calendarHeight = 0;
        });
      if (this.mounted && !visible && showThumbnail)
        setState(() {
          //TODO text memory do controller.text = oldtext when click back
          hideTotalPrice = false;
          showThumbnail = false;
          store.thumbnailExpense = null;
          FocusScope.of(focusNode.context).unfocus();
        });
    });

    if (store.expenses.isEmpty)
      ExpenseProvider.db.getAllExpenses().then((expenses) {
        if (expenses.isEmpty) {
          print('Database value ==> is empty');
        } else {
          store.addAllExpenses(expenses);
          setState(() {});
        }
      });

    if (store.tags.isEmpty)
      TagProvider.db.getAllTags().then((tags) {
        store.addAllTags(tags);

        // print('store tags => ${store.tags}');
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            calendarShowSection(),
            calendar(),
            expensesListWidget(),
            totalPriceWidget(),
            thumbnailWidget(),
            addPriceWidget(),
          ],
        ),
      ),
    );
  }

  //---------------CALENDAR---------------
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
              rowHeight: 35,
              onDaySelected: (day, events) {
                FocusScope.of(focusNode.context).unfocus();
                selectedDate = new DateTime(day.year, day.month, day.day);
                store.updateSelectedDate(selectedDate);
                listKey.currentState.setState(() {});
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: calendarHeight != 0
              ? null
              : () {
                  store.updateSelectedDate(store.selectedDate.subtract(
                    Duration(
                      days: 1,
                    ),
                  ));
                },
        ),
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(4.0),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                border: Border.all(
                  color: Colors.black,
                  width: 3,
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
                            '${date.day}/${date.month}/${date.year}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                      ),
                      onPressed: () async => calendarButtonPressed(),
                    )
                  ],
                ),
              )),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: calendarHeight != 0
              ? null
              : () {
                  store.updateSelectedDate(store.selectedDate.add(
                    Duration(
                      days: 1,
                    ),
                  ));
                },
        ),
      ],
    );
  }

  //---------------EXPENSES LIST WIDGET---------------
  Widget expensesListWidget() {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
          color: Colors.blue[400],
          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12)),
      child: listViewExpenses(),
    ));
  }

  Widget listViewExpenses() {
    return Observer(builder: (_) {
      store.selectedDate;
      List<Expense> selectedDateExpenses = store.selectedDateExpenses;

      //setState(() {});

      return new AnimatedList(
        key: listKey,
        initialItemCount:
            100, // needs to be higher because we change the item count
        itemBuilder: (bc, i, anim) {
          if (selectedDateExpenses.length <= i) return null;

          Expense expense = selectedDateExpenses[i];
          return FadeTransition(
            opacity: anim,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[200],
              ),
              child: ExpenseTile(
                deleteButtonPressed: deleteButtonPressed,
                editButtonPressed: editButtonPressed,
                expense: expense,
              ),
            ),
          );
        },
      );
    });
  }

  Widget thumbnailWidget() {
    return Opacity(
      opacity: 0.5,
      child: Observer(builder: (_) {
        var thumbnailExpense = store.thumbnailExpense;
        if (showThumbnail) {
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue[200],
              ),
              child: ExpenseTile(
                  deleteButtonPressed: null,
                  editButtonPressed: null,
                  expense: thumbnailExpense,
                  isThumbnail: true));
        } else {
          return Container();
        }
      }),
    );
  }

  Widget totalPriceWidget() {
    return Observer(builder: (_) {
      store.selectedDate; //t update when change date
      var totalPrice = store.getSelectedDateTotalPrice();

      return Container(
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        height: hideTotalPrice ? 0 : 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Total Expense: $totalPrice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2
              ),
            ),
          ],
        ),
      );
    });
  }

  //---------------ADD PRICE TEXT FIELD---------------
  Widget addPriceWidget() {
    controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.red[400],
        border: Border.all(
          color: Colors.black,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      height: 80,
      child: Center(
        child: TextField(
          onChanged: (text) async {
            store.setThumbnailExpense(
              await Regex.doRegex(text, store.selectedDate),
            );
          },
          onTap: () async {
            hideTotalPrice = true;
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
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              //focusedBorder: UnderlineInputBorder(),
              hintText: 'Enter a expense'),
        ),
      ),
    );
  }

  //
  //--------------LOGIC--------------
  //

  void textFieldSubmitted(TextEditingController controller) async {
    Expense regexExpense = await Regex.doRegex(
      controller.text,
      store.selectedDate,
    );
    print('regexExpense:\t $regexExpense');
    showThumbnail = false;
    store.thumbnailExpense = null;

    controller.text = '';
    if (editing.isNotEmpty) {
      //EDITING PART

      Expense expenseToAdd = regexExpense;
      expenseToAdd.id = editing.first.id;

      await ExpenseProvider.db.update(expenseToAdd);
      store.updateExpense(expenseToAdd);
      editing.clear();
    } else {
      //ADDING PART

      await ExpenseProvider.db.createExpense(regexExpense);

      store.addExpense(regexExpense);

      if (isSelectedDate(regexExpense))
        listKey.currentState.insertItem(store.selectedDateExpenses.length - 1);
    }
    showThumbnail = false;
    hideTotalPrice = false;
    setState(() {});
  }

  void deleteButtonPressed(int id) {
    //print('deleteButtonPressed');
    Expense expense =
        store.selectedDateExpenses.firstWhere((element) => element.id == id);

    ExpenseProvider.db.delete(expense).then((value) {});

    AnimatedListRemovedItemBuilder builder = (context, anim) {
      return FadeTransition(
        opacity: anim,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue[200],
          ),
          child: ExpenseTile(
            deleteButtonPressed: deleteButtonPressed,
            editButtonPressed: editButtonPressed,
            expense: expense,
          ),
        ),
      );
    };

    listKey.currentState
        .removeItem(store.selectedDateExpenses.indexOf(expense), builder);
    store.deleteExpense(expense);
    setState(() {});
  }

  void editButtonPressed(int id) {
    Expense expense = store.selectedDateExpenses.firstWhere(
      (element) => element.id == id,
    );

    // print('Expense Text : ${expense.text}');
    focusNode.requestFocus();
    // setState(() {});
    controller.text = expense.text;
    editing = {expense};
    print('editing $editing');
    // print('Controller text : ${controller.text}');
  }

  Future calendarButtonPressed() async {
    FocusScope.of(context).unfocus();
    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 200));
      return isKeyboardActive;
    });

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
}
