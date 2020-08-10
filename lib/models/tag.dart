import 'package:flutter/material.dart';

class Tag {
  String name, shorten;
  int hexCode, id;
  Color color;

  Tag({this.id, this.name, this.shorten, this.hexCode, this.color}) {
    shorten ??= name;
    hexCode ??= 0xFFFFA726;
    color ??= Color(hexCode);
  }

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        name: json["name"],
        shorten: json["shorten"],
        hexCode: json["hexCode"],
        color: Color(json["hexCode"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "shorten": shorten,
        "hexCode": hexCode,
      };

  static Tag other() {
    return new Tag(
      name: 'other',
      hexCode: 0xff9e9e9e,
    );
  }

  @override
  String toString() {
    return 'ID:$id Name:$name shorten:$shorten Color:$color';
  }
}
