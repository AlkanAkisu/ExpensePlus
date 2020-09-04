import 'package:flutter/material.dart';

class Tag {
  String name, shorten;
  int hexCode, id;
  Color color;
  static Tag otherTag = Tag(
    name: 'other',
    hexCode: 0xff9e9e9e,
  );

  Tag({this.id, this.name, this.shorten, this.hexCode, this.color}) {
    shorten ??= name;
    if (color == null)
      hexCode ??= 0xFFFFA726;
    else
      hexCode = color.value;
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
    return Tag.otherTag;
  }

  @override
  String toString() {
    return 'ID:$id Name:$name shorten:$shorten Color:$color';
  }
}
