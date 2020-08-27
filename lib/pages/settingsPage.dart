import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/limit_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';
import 'package:tracker_but_fast/pages/graphPage.dart';

import '../expenses_store.dart';

enum Data {
  tag,
  expense,
  all,
}

class SettingsPage extends HookWidget {
  ValueNotifier<double> amount;
  final store = MobxStore.st;

  @override
  Widget build(BuildContext context) {
    amount = useState(null);

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
        body: SingleChildScrollView(
          child: Observer(builder: (_) {
            store.limitMap;
            store.isAutomatic;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // #region LIMIT
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
                    value: store.isAutomatic,
                    onChanged: (isChecked) {
                      store.isAutomatic = isChecked;
                      if (store.isAutomatic) store.automaticSet(true);
                      LimitProvider.db.updateIsAutomatic(isChecked);
                    },
                  )
                  //todo implent
                  ,
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
                  subtitle: Text(
                    store.limitMap[ViewType.Month]?.toString() ??
                        'Not configured',
                  ),
                  onTap: () => configureLimit(context, ViewType.Month),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  enabled: !store.isAutomatic,
                  title: Text(
                    'Configure Weekly Limit',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    store.limitMap[ViewType.Week]?.toString() ??
                        'Not configured',
                  ),
                  onTap: () => configureLimit(context, ViewType.Week),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  enabled: !store.isAutomatic,
                  title: Text(
                    'Configure Daily Limit',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    store.limitMap[ViewType.Day]?.toString() ??
                        'Not configured',
                  ),
                  onTap: () => configureLimit(context, ViewType.Day),
                ),
                Divider(
                  thickness: 1,
                ),
                // #endregion

                // #region DATA
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
                // #endregion
              ],
            );
          }),
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

  Future<void> configureLimit(BuildContext bc, ViewType viewType) async {
    TextStyle style = new TextStyle(
      fontSize: 18,
      letterSpacing: 1,
    );

    amount.value = await showDialog(
      context: bc,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Set ${viewtypeToString(viewType)} Limit',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: TextField(
                keyboardType: TextInputType.number,
                onSubmitted: (data) => Navigator.pop(
                  context,
                  double.parse(data),
                ),
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(),
                  hintText: 'Enter a amount',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, null);
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
    );

    if (amount.value != null) {
      store.setLimit(viewType, amount.value, true);
      if (store.isAutomatic) store.automaticSet(true);
    }
  }

  String viewtypeToString(ViewType vt) => {
        ViewType.Day: 'Daily',
        ViewType.Month: 'Monthly',
        ViewType.Week: 'Weekly,'
      }[vt];

// #endregion

}
