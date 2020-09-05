import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:expensePlus/database/expense_provider.dart';
import 'package:expensePlus/database/settings_provider.dart';
import 'package:expensePlus/database/tag_provider.dart';
import 'package:expensePlus/pages/graphPage.dart';

import '../expenses_store.dart';

enum Data {
  tag,
  expense,
  all,
}

class SettingsPage extends HookWidget {
  ValueNotifier<double> amount;
  ValueNotifier<String> dateStyle;
  final store = MobxStore.st;

  @override
  Widget build(BuildContext context) {
    amount = useState(null);
    dateStyle = useState(store.dateStyle);

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
                  leading: Switch(
                    value: store.isUseLimit ?? false,
                    onChanged: (isChecked) {
                      store.setUseLimit(
                        isChecked,
                        setDatabase: true,
                      );
                    },
                  )
                  //todo implent
                  ,
                  title: Text(
                    'Use Limit',
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
                  enabled: (store.isUseLimit ?? false),
                  leading: Checkbox(
                    value: store.isAutomatic,
                    onChanged: (store.isUseLimit ?? false)
                        ? (isChecked) {
                            store.isAutomatic = isChecked;
                            if (store.isAutomatic)
                              store.automaticSet(setDatabase: true);
                          }
                        : null,
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
                    enabled: store.isUseLimit ?? false,
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
                    trailing: deleteLimitButton(ViewType.Month)),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  enabled: (store.isUseLimit ?? false) && !store.isAutomatic,
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
                  trailing: deleteLimitButton(ViewType.Week),
                ),
                Divider(
                  thickness: 1,
                ),
                ListTile(
                  enabled: (store.isUseLimit ?? false) && !store.isAutomatic,
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
                  trailing: deleteLimitButton(ViewType.Day),
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

                // #region DateStyle
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Text(
                    'Date Style',
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
                    'Set Date Style',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () async => await configureDateStyle(context),
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

  Widget deleteLimitButton(ViewType type) {
    bool disabled = false;
    if (type != ViewType.Month && store.isAutomatic) disabled = true;
    if (store.limitMap[type] == null) disabled = true;
    if (!store.isUseLimit) disabled = true;
    const double kSize = 40;
    return Container(
      decoration: BoxDecoration(
        color: !disabled ? Colors.red[400] : Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        constraints: BoxConstraints(
          maxHeight: kSize,
          maxWidth: kSize,
        ),
        onPressed: !disabled
            ? () {
                store.setLimit(type, null);
              }
            : null,
        icon: Icon(
          Icons.clear,
          color: Colors.white,
        ),
        highlightColor: Colors.red,
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
                'Delete Both',
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
    var amountEntered;
    TextStyle style = new TextStyle(
      fontSize: 18,
      letterSpacing: 1,
    );

    String viewtypeToString(ViewType vt) => {
          ViewType.Day: 'Daily',
          ViewType.Month: 'Monthly',
          ViewType.Week: 'Weekly,'
        }[vt];

    final controller = TextEditingController();
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
                controller: controller,
                keyboardType: TextInputType.number,
                onSubmitted: (data) {
                  print('onSubmit $data');
                  amountEntered = data;
                  if (data.isEmpty)
                    Navigator.pop(context, null);
                  else
                    Navigator.pop(
                      context,
                      double.parse(data),
                    );
                },
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
                amountEntered = null;
                if (controller.text.isNotEmpty && controller.text != null)
                  amountEntered = double.parse(controller.text);
                Navigator.pop(context, amountEntered);
              },
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green[100]),
                  child: Text(
                    'Submit',
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
      store.setLimit(
        viewType,
        amount.value,
        setDatabase: true,
      );
      if (store.isAutomatic) store.automaticSet(setDatabase: true);
    }
  }

  Future<void> configureDateStyle(BuildContext bc) async {
    TextStyle style = new TextStyle(
      fontSize: 18,
      letterSpacing: 1,
    );

    dateStyle.value = await showDialog(
      context: bc,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Set Date Style',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'dd/mm');
              },
              child: Center(
                child: Container(
                  color: store.dateStyle == 'dd/mm'? Colors.blue[100]:null,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'dd/mm/yyyy',
                    style: style,
                  ),
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'mm/dd');
              },
              child: Center(
                child: Container(
                  color: store.dateStyle == 'mm/dd'? Colors.blue[100]:null,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'mm/dd/yyyy',
                    style: style,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (dateStyle?.value != null) {
      await SettingsProvider.db.changeDateStyle(dateStyle.value);
      store.dateStyle = dateStyle.value;
      final date = DateTime.parse(store.selectedDate.toIso8601String());
      store.updateSelectedDate(date);
      store.updateGraphSelectedDate(date);
    }
  }

// #endregion

}
