import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker_but_fast/models/expense.dart';
import 'package:tracker_but_fast/expenses_store.dart';
import 'package:tracker_but_fast/models/tag.dart';

class ExpenseTile extends StatefulWidget {
  Expense expense;
  bool isThumbnail;

  ExpenseTile({
    this.expense,
    this.isThumbnail,
  }) {
    expense ??= Expense.empty();
  }
  @override
  _ExpenseTileState createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile> {
  @override
  Widget build(BuildContext context) {
    return expenseTile(widget.expense);
  }

  Widget expenseTile(Expense expense) {
    return Container(
      width: double.infinity,
      height: 80,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          //BUTTON SECTION
          // buttonsHeader(),

          //TEXT SECTION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(flex: 5, child: expenseNameText(expense)),
                  Expanded(flex: 3, child: tagRow(expense)),
                ],
              ),
            ),
          ),
          priceSection(expense)
        ],
      ),
    );
  }

  Widget buttonsHeader() {
    return Column(
      children: <Widget>[
        Expanded(
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => {
              // if (widget.isThumbnail == null)
              //   widget.deleteButtonPressed(widget.expense.id)
            },
            color: Colors.red[400],
          ),
        ),
        Expanded(
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => {
              // if (widget.isThumbnail == null)
              //   widget.editButtonPressed(widget.expense.id)
            },
          ),
        ),
      ],
    );
  }

  Widget expenseNameText(Expense expense) {
    return Container(
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Align(
            alignment: FractionalOffset.centerLeft,
            child: Text(
              expense?.name ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget tagRow(Expense expense) {
    if (expense.tags == null) {
      expense.tags = [Tag.otherTag];
    }
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: expense.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                )
              ], borderRadius: BorderRadius.circular(5), color: tag.color),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: useWhiteForeground(tag.color)
                        ? const Color(0xffffffff)
                        : const Color(0xff000000),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget priceSection(Expense expense) {
    if (expense.prices == null) {
      expense.prices = [0];
    }
    double totalPrice = expense?.getTotalExpense() ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: expense.prices.map((price) {
                return Container(
                  constraints: BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      )
                    ],
                    borderRadius: BorderRadius.circular(50),
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue[300],
                        Colors.blue[400],
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      price.toString(),
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            constraints: BoxConstraints(
              minWidth: 70,
              minHeight: 70,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
            height: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                )
              ],
              borderRadius: BorderRadius.circular(50),
              gradient: RadialGradient(
                colors: [
                  Colors.blue[300],
                  Colors.blue[400],
                ],
              ),
            ),
            child: Center(
              child: Text(
                totalPrice.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
