import 'package:flutter/material.dart';
import 'package:tracker_but_fast/models/tag.dart';
import 'package:tracker_but_fast/models/expense.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';

class Regex {
  //REGEX
  static RegExp priceRegex =
      RegExp(r'((?<=\s|^)\d+\.*\d*(?=\s|$))', caseSensitive: false);
  static RegExp tagRegex = RegExp(r'(?<=\.)(\S+)', caseSensitive: false);
  static RegExp limitRegex = RegExp(r'(-lim+)', caseSensitive: false);
  static RegExp dateRegex = RegExp(
      r'(?<=#)(([0-9]+)+([a-z]+))|(?<=#)([a-z]+)|(?<=#)(\d+\.*\d*)',
      caseSensitive: false);

  static DateTime dateFormatter(Map<String, dynamic> map) {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int howMany = map['howMany'];
    switch (map['keyword']) {
      case 'tommorrow':
      case 'tom':
        return now.add(Duration(days: 1));
      case 'today':
      case 'tod':
      case 't':
        return now;
      case 'yesterday':
      case 'yest':
      case 'y':
        return now.subtract(Duration(days: 1));
      case 'lastweek':
        return now.subtract(Duration(days: 7));
      case 'week':
      case 'w':
        return now.subtract(Duration(days: 7 * howMany));
      case 'day':
      case 'd':
        return now.subtract(Duration(days: 1 * howMany));
    }
    return null;
  }

  ///input [str] for regex
  /// returns tags, prices and isLimit
  static Future<Expense> doRegex(String str, DateTime selectedDate) async {
    String text = str;
    //Todo implement more than one expense at once
    String name;
    List<Tag> tags = new List();
    List<double> prices = new List();
    bool limit;
    DateTime date;

    str = str.trim();

    priceRegex.allMatches(str).forEach((el) {
      prices.add(double.parse(el[0]));
    });
    str = str.replaceAll(priceRegex, '');

    if (tagRegex.allMatches(str).isEmpty)
      tags = [
        Tag.other()
      ];
    for (final el in tagRegex.allMatches(str)) {
      Tag tag = await TagProvider.db.searchTag(el[0]);
      print('REGEX:\t database tag $tag ');
      tag ??= new Tag(
        name: el[0],
      );
      tags.add(tag);
      print('REGEX:\t tags list $tag ');
    }

    str = str.replaceAll(tagRegex, '');

    //print('found match ${dateRegex.allMatches(str).length}');
    dateRegex.allMatches(str).forEach((el) {
      //print('Regex Groups => ${el.groups([1, 2, 3, 4, 5])}');
      //#29 #9.12 style
      if (el[5] != null) {
        final map = el[5].split('.').asMap();

        date = new DateTime(
          DateTime.now().year,
          int.parse(map[1] ?? DateTime.now().month.toString()),
          int.parse(map[0]),
        );
      } else {
        var howMany = el[2] != null ? int.parse(el[2]) : 1;
        var keyword = el[3] ?? el[4];
        Map<String, dynamic> map = {
          'keyword': keyword,
          'howMany': howMany,
        };

        date = dateFormatter(map);
        print('How Many:$howMany\t Keyword:$keyword\t Date:$date');
      }
    });
    date ??= selectedDate;
    str = str.replaceAll(dateRegex, '');

    limitRegex.allMatches(str).forEach((el) {
      if (el[0] != null) limit = false;
      str = str.replaceRange(el.start, el.end, '');
    });

    str = str.replaceAll(limitRegex, '');
    str = str.replaceAll(new RegExp(r'[\.|#]+'), '');
    str = str.trim();

    //todo TEST IT
    name = str.isEmpty ? tags.map((e) => e.name).join(' ') : str;
    prices = prices.isEmpty ? [0] : prices;

    limit ??= true;

    Expense rv = new Expense(
      name: name,
      tags: tags,
      prices: prices,
      text: text,
      limit: limit,
      date: date,
    );
    return rv;
  }
}
