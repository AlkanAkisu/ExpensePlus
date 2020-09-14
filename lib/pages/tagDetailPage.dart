import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/models/expense.dart';
import 'package:expensePlus/models/tag.dart';
import 'package:expensePlus/widgets/expenseTile.dart';

class TagDetailPage extends HookWidget {
  TagDetailPage(this.tag);

  final Tag tag;
  final store = MobxStore.st;
  ValueNotifier<bool> isExpensesExist;
  ValueNotifier<List<Tag>> checkboxs;
  ValueNotifier<DateTime> from;
  ValueNotifier<DateTime> to;

  @override
  Widget build(BuildContext context) {
    checkboxs = useState([tag]);
    from = useState(null);
    to = useState(null);
    isExpensesExist = useState(expensesNeedsShow().isNotEmpty);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Text(
          'Tag Details',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              filterSection(context),
              isExpensesExist.value
                  ? Text(
                      'Hint: Click An Expense To Go Add Expense Page',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                    )
                  : Container(),
              tagExpenseList(),
            ],
          ),
        ),
      ),
    );
  }
  // #region UI

  Widget filterSection(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Colors.black87,
          ),
        ],
        color: Colors.blue[700],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Filters:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 160,
                  ),
                  child: filterBox(
                    onTap: () async =>
                        await handleMultipleTagSelection(context),
                    text: 'Select Tags',
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 120,
                  ),
                  child: filterBox(
                    onTap: () async => await handleDateSelection(context),
                    text: 'Select Dates',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget filterBox({Function onTap, String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.blue[600],
            border: Border.all(
              width: 1.5,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 1,
                color: Colors.white,
              )
            ]),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget tagExpenseList() {
    return Builder(builder: (context) {
      return Container(
        child: SingleChildScrollView(
          child: tagExpenses(),
        ),
      );
    });
  }

  Widget tagExpenses() {
    List<MapEntry<DateTime, List<Expense>>> entries = expensesNeedsShow();

    entries.sort((me1, me2) => me1.key.compareTo(me2.key));

    List<Widget> listTiles = new List();

    entries.forEach((entry) {
      var date = entry.key;
      var expenses = entry.value;
      Color calendarTileColor = Colors.blue[700];
      listTiles.add(
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: calendarTileColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            title: Text(
              store.dateStyle == 'dd/mm'
                  ? '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}'
                  : '${date.month.toString().padLeft(2, '0')} / ${date.day.toString().padLeft(2, '0')} / ${date.year}',
              style: TextStyle(
                  color: calendarTileColor, fontWeight: FontWeight.w500),
            ),
            leading: Icon(Icons.calendar_today, color: calendarTileColor),
          ),
        ),
      );
      listTiles.addAll(
        expenses.map((e) => GestureDetector(
              onTap: () {
                MobxStore.st.currentIndex = 1;
                store.updateSelectedDate(e.date);
                store.updateGraphSelectedDate(e.date);
                MobxStore.st.navigatorKey.currentState.pop();
              },
              child: ExpenseTile(
                expense: e,
              ),
            )),
      );
    });

    return Column(
      children: listTiles,
    );
  }

  // #endregion

  // #region LOGIC

  List<MapEntry<DateTime, List<Expense>>> expensesNeedsShow() {
    List<Expense> selectedExpense = store.expenses.fold(
      [],
      (prev, exp) {
        if (needsToShow(exp)) return [...prev, exp];
        return prev;
      },
    );

    Map<DateTime, List<Expense>> map = selectedExpense.fold(
      {},
      (prev, exp) {
        DateTime date = exp.date;
        if (prev[date] == null) prev[date] = [];
        prev[date].add(exp);
        return prev;
      },
    );

    List<MapEntry<DateTime, List<Expense>>> entries = map.entries.toList();
    return entries;
  }

  handleMultipleTagSelection(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text(
                'What tags do you want to choose?',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              children: <Widget>[
                ...store.tags.map((t) {
                  return CheckboxListTile(
                    value: checkboxs.value.contains(t),
                    activeColor: t.color,
                    title: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 6),
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: t.color,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                )
                              ],
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: t.color,
                                width: 1,
                              )),
                          child: Text(
                            t.name,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: t.color,
                            ),
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                    onChanged: (check) {
                      setState(() {
                        if (check)
                          checkboxs.value = [...checkboxs.value, t];
                        else if (checkboxs.value.length == 1)
                          return;
                        else
                          checkboxs.value = new List.from(checkboxs.value)
                            ..remove(t);
                        isExpensesExist.value = expensesNeedsShow().isNotEmpty;
                      });
                    },
                  );
                }).toList(),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, checkboxs);
                  },
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green[100]),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  handleDateSelection(BuildContext context) async {
    VoidCallback checkFromTo = () {
      if (to.value != null && from.value != null) {
        if (from.value.isAfter(to.value)) {
          //from must before to
          final oldEarlyValue = to.value;
          to.value = from.value;
          from.value = oldEarlyValue;
        }
      }
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return SimpleDialog(
            title: Text(
              'What days do you want to choose?',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            children: <Widget>[
              //FROM
              SimpleDialogOption(
                onPressed: () async {
                  from.value = await showDatePicker(
                    helpText: 'Select Initial Date',
                    context: context,
                    initialDate: from.value ?? store.selectedDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2030),
                  );
                  checkFromTo();
                  setState(() {});
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blue[700], width: 1.5)),
                    child: Text(
                      from.value != null
                          ? store.dateStyle == 'dd/mm'
                              ? ' From: ${from.value.day.toString().padLeft(2, '0')}/${from.value.month.toString().padLeft(2, '0')}/${from.value.year}'
                              : ' From: ${from.value.month.toString().padLeft(2, '0')}/${from.value.day.toString().padLeft(2, '0')}/${from.value.year}'
                          : ' From: Not Selected',
                      style: TextStyle(
                          color: Colors.blue[700], fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              //TO
              SimpleDialogOption(
                onPressed: () async {
                  to.value = await showDatePicker(
                    helpText: 'Select Initial Date',
                    context: context,
                    initialDate: to.value ?? store.selectedDate,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2030),
                  );
                  checkFromTo();
                  setState(() {});
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.blue[700], width: 1.5)),
                    child: Text(
                      to.value != null
                          ? store.dateStyle == 'dd/mm'
                              ? 'To: ${to.value.day.toString().padLeft(2, '0')}/${to.value.month.toString().padLeft(2, '0')}/${to.value.year}'
                              : 'To: ${to.value.month.toString().padLeft(2, '0')}/${to.value.day.toString().padLeft(2, '0')}/${to.value.year}'
                          : 'To: Not Selected',
                      style: TextStyle(
                          color: Colors.blue[700], fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),

              SimpleDialogOption(
                onPressed: () {
                  to.value = null;
                  from.value = null;
                  setState(() {});
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.red[100]),
                    child: Text(
                      'Clear Dates',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),

              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, checkboxs);
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green[100]),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  bool needsToShow(Expense expense) {
    List<Tag> tags = expense.tags;
    DateTime date = expense.date;
    var needs = false;

    final isSameDay = (DateTime date1, DateTime date2) =>
        date1.day == date2.day &&
        date1.month == date2.month &&
        date1.year == date2.year;

    for (var checked in checkboxs.value) {
      bool after = from.value != null
          ? date.isAfter(from.value) || isSameDay(date, from.value)
          : true;

      bool before = to.value != null
          ? date.isBefore(to.value) || isSameDay(date, to.value)
          : true;

      if (tags.contains(checked) && after && before) {
        needs = true;
        break;
      }
    }
    return needs;
  }

// #endregion

}
