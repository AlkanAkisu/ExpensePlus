import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/models/tag.dart';
import 'package:expensePlus/models/expense.dart';
import 'package:expensePlus/database/tag_provider.dart';

class Regex {
  //REGEX
  static RegExp priceRegex =
      RegExp(r'((?<=\s|^)\d+\.*\d*(?=\s|$))', caseSensitive: false);
  static RegExp tagRegex =
      RegExp(r'(?:(?:^|[\s]+)\.([^\.\s]+))', caseSensitive: false);
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
  static Future<Expense> doRegex(
    String str,
    DateTime selectedDate,
    bool submitted,
  ) async {
    String text = str;

    String name;
    List<Tag> tags = new List();
    List<double> prices = new List();
    bool limit;
    DateTime date;

    str = str.trim();

    priceRegex.allMatches(str).forEach(
      (el) {
        prices.add(double.parse(double.parse(el[1]).toStringAsFixed(2)));
      },
    );
    str = str.replaceAll(priceRegex, '');

    dateRegex.allMatches(str).forEach((el) {
      //#29 #9.12 style
      if (el[5] != null) {
        final map = el[5].split('.').asMap();
        int month;
        if (map[1] != null) {
          if (map[1].isNotEmpty) month = int.parse(map[1]);
        }
        month ??= DateTime.now().month;
        int day = int.parse(map[0]);


        date = new DateTime(
          DateTime.now().year,
          month,
          day,
        );

        //todo wrong date entered handle it
        if (date.month != month || date.day != day) {

          date = selectedDate;
        }
      } else {
        var howMany = el[2] != null ? int.parse(el[2]) : 1;
        var keyword = el[3] ?? el[4];
        Map<String, dynamic> map = {
          'keyword': keyword,
          'howMany': howMany,
        };

        date = dateFormatter(map);
      }
    });
    date ??= selectedDate;
    str = str.replaceAll(dateRegex, '');

    //TAG
    if (tagRegex.allMatches(str).isEmpty) tags = [Tag.other()];



    for (final el in tagRegex.allMatches(str)) {
      String name = el[1];
      Tag tag = MobxStore.st.getTagByName(name);
      if (tag == null) {
        tag = new Tag(
          name: name,
        );
        if (submitted) MobxStore.st.addTag(tag, setDatabase: true);
      }
      tags.add(tag);
    }

    str = str.replaceAll(tagRegex, '');

    limitRegex.allMatches(str).forEach((el) {
      if (el[1] != null) limit = false;
      str = str.replaceRange(el.start, el.end, '');
    });

    str = str.replaceAll(limitRegex, '');
    str = str.replaceAll(new RegExp(r'[\.|#]+'), '');
    str = str.trim();

    name = str.isEmpty || str == null ? tags.map((e) => e.name).join(' ') : str;
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
