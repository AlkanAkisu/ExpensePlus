library rich_text_controller;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RichTextController extends TextEditingController {
  final Map<RegExp, TextStyle> patternMap;
  final Function(List<String> match) onMatch;
  final double kFontSize = 20;
  RichTextController(this.patternMap, {this.onMatch})
      : assert(patternMap != null);

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    List<TextSpan> children = new List();
    List<RegExpMatch> matches = new List();

    for (final regex in patternMap.keys) {
      final matchesNeedsAdd = regex.allMatches(text);
      if (matchesNeedsAdd.isNotEmpty)
        matches = [...matches, ...matchesNeedsAdd];
    }
    matches.sort((a, b) => a.start - b.start);
    int start = 0, end;

    for (final match in matches) {
      end = match.start;

      children.add(TextSpan(
        style: TextStyle(color: Colors.black, fontSize: kFontSize),
        text: text.substring(start, end),
      ));
      children.add(TextSpan(
        style: patternMap[match.pattern].merge(TextStyle(
          fontSize: kFontSize,
        )),
        text: text.substring(match.start, match.end),
      ));
      start = match.end;
    }

    children.add(TextSpan(
      style: TextStyle(color: Colors.black, fontSize: kFontSize),
      text: text.substring(start),
    ));
    if (children.isNotEmpty) return TextSpan(children: children);
    return TextSpan(style: TextStyle(color: Colors.black, fontSize: kFontSize));
  }
}
