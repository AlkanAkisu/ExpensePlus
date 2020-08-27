import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker_but_fast/models/tag.dart';

class TagTile extends StatelessWidget {
  const TagTile({
    Key key,
    @required this.tag,
  }) : super(key: key);

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Center(child: tagContainer(tag.name, width))),
          Expanded(child: Center(child: tagContainer(tag.shorten, width))),
        ],
      ),
    );
  }

  Widget tagContainer(String str, double width) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: tag.color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        str,
        style: TextStyle(
          fontSize: 18,
          letterSpacing: 1,
          color: tag.color,
        ),
      ),
    );
  }
}
