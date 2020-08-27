import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';

import '../expenses_store.dart';

enum Data {
  tag,
  expense,
  all,
}

class SettingsPage extends HookWidget {
  ValueNotifier<bool> isAutomatic;
  @override
  Widget build(BuildContext context) {
    isAutomatic = useState(true);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[700],
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Text(
                'Configure Limit',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: Checkbox(
                value: isAutomatic.value,
                onChanged: (isChecked) {
                  isAutomatic.value = isChecked;
                  print('checked is $isChecked');
                },
              ),
              title: Text(
                'Automatic Limits By Month',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              title: Text(
                'Configure Monthly Limit',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              enabled: !isAutomatic.value,
              title: Text(
                'Configure Weekly Limit',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              enabled: !isAutomatic.value,
              title: Text(
                'Configure Daily Limit',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                'Data',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Delete Data',
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () async => await deleteDataPressed(context),
            ),
            Divider(
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  // #region LOGIC

  Future<void> deleteDataPressed(BuildContext bc) async {
    TextStyle style = new TextStyle(
      fontSize: 18,
      letterSpacing: 1,
    );
    switch (await showDialog(
      context: bc,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'What do you want to delete?',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              onPressed: () {
                Navigator.pop(context, Data.tag);
              },
              child: Text(
                'Delete Tags',
                style: style,
              ),
            ),
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              onPressed: () {
                Navigator.pop(context, Data.expense);
              },
              child: Text(
                'Delete Expenses',
                style: style,
              ),
            ),
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              onPressed: () {
                Navigator.pop(context, Data.all);
              },
              child: Text(
                'Delete All',
                style: style,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red[100]),
                  child: Text(
                    'Cancel',
                    style: style,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    )) {
      case Data.expense:
        await ExpenseProvider.db.deleteAll();
        MobxStore.st.deleteAll();
        break;
      case Data.tag:
        await TagProvider.db.deleteAll();
        MobxStore.st.deleteAllTags();
        break;
      case Data.all:
        await ExpenseProvider.db.deleteAll();
        MobxStore.st.deleteAll();
        await TagProvider.db.deleteAll();
        MobxStore.st.deleteAllTags();
        break;
      default:
    }
  }
// #endregion

}
