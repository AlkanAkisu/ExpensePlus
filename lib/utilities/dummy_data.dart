import 'package:flutter/material.dart';
import 'package:expensePlus/models/expense.dart';

import '../models/tag.dart';

class DummyData {
  static List<Expense> expenses() {
    return [
      new Expense(
        name: 'Taxi',
        tags: [
          new Tag(
              name: 'travel', hexCode: Colors.purple[400].value, shorten: 't'),
        ],
        prices: [25.0],
        text: 'Taxi .t 15',
        date: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
      ),
      new Expense(
        name: 'Bowling',
        tags: [
          new Tag(name: 'bowling', hexCode: Colors.black.value, shorten: 'b'),
          new Tag(
              name: 'friends', hexCode: Colors.red[400].value, shorten: 'f'),
        ],
        prices: [15.0, 5.0],
        text: 'Bowling .b .f 30 20',
        date: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
      ),
      new Expense(
        name: 'Hangout',
        tags: [
          new Tag(
              name: 'friends', hexCode: Colors.red[400].value, shorten: 'f'),
        ],
        prices: [45],
        text: 'Hangout .bowling 45',
        date: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ).add(
          Duration(
            days: 1,
          ),
        ),
      ),
    ];
  }

  static List<Tag> tags() {
    return [
      new Tag(name: 'travel', hexCode: Colors.purple[400].value, shorten: 't'),
      new Tag(name: 'bowling', hexCode: Colors.black.value, shorten: 'b'),
      new Tag(name: 'friends', hexCode: Colors.red[400].value, shorten: 'f'),
    ];
  }
}
