import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:expensePlus/models/tag.dart';
import 'package:expensePlus/pages/tagDetailPage.dart';

class TagTile extends StatelessWidget {
  const TagTile({
    Key key,
    @required this.tag,
    @required this.editButtonCallback,
  }) : super(key: key);

  final Tag tag;
  final Function editButtonCallback;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => MobxStore.st.navigatorKey.currentState.push(
        MaterialPageRoute(
          builder: (_) => TagDetailPage(tag),
        ),
      ),
      child: Slidable(
        actionPane: SlidableStrechActionPane(),
        direction: Axis.horizontal,
        actionExtentRatio: 0.5,
        actions: <Widget>[
          IconSlideAction(
            caption: 'Edit',
            color: Colors.blue,
            icon: Icons.edit,
            onTap: () => editButtonPressed(),
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => deleteButtonPressed(),
          ),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: Center(child: tagContainer(tag.name, width))),
            Expanded(child: Center(child: tagContainer(tag.shorten, width))),
          ],
        ),
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

  deleteButtonPressed() async {
    await MobxStore.st.deleteTag(
      tag,
      setDatabase: true,
    );
    Fluttertoast.showToast(
      msg: 'Tag has been deleted',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red[400],
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  editButtonPressed() {
    MobxStore.st.editTag = tag;
    editButtonCallback();
  }
}
