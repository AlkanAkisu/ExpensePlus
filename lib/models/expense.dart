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
    date ??= DateTime.now();
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    List<Tag> tags = List();
    json["tags"].forEach((element) {
      tags.add(Tag.fromJson(element));
    });
    List<double> prices = List();
    json["prices"]?.forEach((element) {
      prices.add(element);
    });
    return Expense(
      id: json["id"],
      text: json["text"],
      name: json["name"],
      tags: tags,
      prices: prices,
      limit: json["limit"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
    );
  }

  static Expense empty() {
    return new Expense(
      name: '',
      prices: [0],
      tags: [
        new Tag(
          name: 'other',
          hexCode: 0xff9e9e9e,
        )
      ],
      limit: true,
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
