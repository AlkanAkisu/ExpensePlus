import 'package:expensePlus/expenses_store.dart';

import 'tag.dart';

class Expense {
  int id;
  String name;
  String text;
  List<Tag> tags;
  List<double> prices;
  bool limit;
  DateTime date;

  Expense({
    this.id,
    this.text,
    this.name,
    this.tags,
    this.prices,
    this.limit,
    this.date,
  }) {
    prices = prices == null ? [0] : prices.isEmpty ? [0] : prices;
    date ??= DateTime.now();
    date = DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static Expense empty() {
    return new Expense(
      name: '',
      prices: [0],
      tags: [
        Tag.otherTag,
      ],
      limit: true,
    );
  }

  double getTotalExpense() =>
      prices.reduce((value, element) => value + element);

  factory Expense.fromJson(Map<String, dynamic> json) {
    List<Tag> tags = List();
    json["tags"].forEach((element) {
      if (element['name'] == 'other')
        tags.add(Tag.otherTag);
      else
        tags.add(MobxStore.st.getTagByName(element['name']));
    });
    List<double> prices = List();
    json["prices"]?.forEach((element) {
      prices.add(element);
    });
    prices = prices.isEmpty || prices == null ? [0] : prices;
    DateTime date = json["date"] != null ? DateTime.parse(json["date"]) : null;
    date = DateTime(date.year, date.month, date.day);
    return Expense(
      id: json["id"],
      text: json["text"],
      name: json["name"],
      tags: tags,
      prices: prices,
      limit: json["limit"],
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "text": text,
        "tags": tags.map((e) => e.toJson()).toList(),
        "prices": prices,
        "limit": limit,
        "date": date?.toIso8601String(),
      };

  String toString() {
    return 'ID:$id Text:$text Name:$name Tags:$tags Prices:$prices Limit:$limit Date:$date\n';
  }
}
