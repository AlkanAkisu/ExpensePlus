import 'package:flutter/material.dart';
import 'package:tracker_but_fast/models/expense.dart';

import '../models/tag.dart';

class DummyData {
  static getData() {
    return [
      new Expense(
        name: 'Taksi',
        tags: [
          new Tag(
            name: 'ulasim',
            hexCode: 0xFF2196F3,
          )
        ],
        prices: [15.0],
        text: 'Taksi .ulasim 15',
        limit: true,
        date: DateTime.now(),
      ),
      new Expense(
        name: 'Alkol',
        tags: [
          new Tag(
            name: 'icki',
            hexCode: 0xFFF44336 ,
          ),
          new Tag(
            name: 'eglence',
            hexCode: 0xFF9C27B0,
          ),
        ],
        prices: [30.0, 20.0],
        text: 'Alkol .icki .eglence 30 20',
        limit: true,
        date: DateTime.now(),
      ),
    ]..forEach((element) {

      });
  }
}
