import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';
import 'package:tracker_but_fast/expenses_store.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker_but_fast/models/tag.dart';

class TagsPage extends HookWidget {
  BuildContext context;
  ValueNotifier<Color> currentColor;
  ValueNotifier<String> buttonName;
  TextEditingController nameController = new TextEditingController();
  TextEditingController shortenController = new TextEditingController();
  final store = MobxStore.st;
  FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    currentColor = useState(Color(Colors.red[300].value));
    buttonName = useState('Change Tag Color');
    this.context = context;


    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Container(
            color: const Color(0xfff9f9f9),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buttons(),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  tagAdder()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buttons() {
    return [
      Container(
        child: IconButton(
          icon: Icon(Icons.delete_sweep),
          color: Colors.red,
          iconSize: 36,
          onPressed: () async {
            await ExpenseProvider.db.deleteAll();
            MobxStore.st.deleteAll();
          },
        ),
      ),
      Container(
        child: IconButton(
          icon: Icon(Icons.storage),
          tooltip: 'Delete DB',
          color: Colors.red,
          iconSize: 36,
          onPressed: () async {
            await ExpenseProvider.db.deleteAll();
          },
        ),
      ),
      Container(
        child: IconButton(
          icon: Icon(Icons.store),
          tooltip: 'Delete Store',
          color: Colors.red,
          iconSize: 36,
          onPressed: () {
            MobxStore.st.deleteAll();
          },
        ),
      ),
    ];
  }

  Widget tagAdder() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: 200,
            height: 100,
            child: TextField(
              textInputAction: TextInputAction.send,
              controller: nameController,
              decoration: InputDecoration(
                  hintText: 'Tag Name (e.g. travel)',
                  floatingLabelBehavior: FloatingLabelBehavior.auto),
              onChanged: (str) {
                buttonName.value = str;
                focusNode.requestFocus();
              },
            ),
          ),
          Container(
            width: 200,
            height: 100,
            child: TextField(
              focusNode: focusNode,
              controller: shortenController,
              decoration: InputDecoration(
                hintText: 'Short Name (e.g. t)',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
            ),
          ),
          Center(
            child: RaisedButton(
              elevation: 3.0,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0.0),
                      contentPadding: const EdgeInsets.all(0.0),
                      content: SingleChildScrollView(
                        child: MaterialPicker(
                          pickerColor: currentColor.value,
                          onColorChanged: (color) {
                            currentColor.value = color;
                            Navigator.pop(context);
                            FocusScope.of(context).unfocus();
                          },
                          enableLabel: true,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text(
                buttonName.value.isEmpty
                    ? 'Change Tag Color'
                    : buttonName.value,
              ),
              color: currentColor.value,
              textColor: useWhiteForeground(currentColor.value)
                  ? const Color(0xffffffff)
                  : const Color(0xff000000),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            iconSize: 36,
            onPressed: () async => addTagButtonPressed(),
          ),
        ],
      ),
    );
  }

  //LOGIC

  Future addTagButtonPressed() async {
    if (nameController.text == null) return;
    Tag tag = await TagProvider.db.createTag(
      nameController.text,
      shortenController.text,
      currentColor.value.value,
    );

    nameController.text = '';
    shortenController.text = '';
    FocusScope.of(context).unfocus();

    //DB and STORE
    MobxStore.st.addTag(tag);
    //await ExpenseProvider.db.updateTags(tag);
  }
}
