import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';
import 'package:tracker_but_fast/expenses_store.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tracker_but_fast/models/tag.dart';
import 'package:tracker_but_fast/widgets/tagTile.dart';

class TagsPage extends HookWidget {
  BuildContext context;
  ValueNotifier<Color> currentColor;
  ValueNotifier<String> buttonName;
  TextEditingController nameController = new TextEditingController();
  TextEditingController shortenController = new TextEditingController();
  final store = MobxStore.st;
  FocusNode focusNode;
  final Color kDefaultColor = Colors.blue[500];

  @override
  Widget build(BuildContext context) {
    currentColor = useState(Color(kDefaultColor.value));
    buttonName = useState('Change Tag Color');
    this.context = context;
    double kHeight = 40.0;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          color: const Color(0xfff9f9f9),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: kHeight + 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    width: double.infinity,
                    height: kHeight,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: kDefaultColor,
                            borderRadius: BorderRadius.circular(5)),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            'ADD TAG',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 1.5,
                                color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              tagAdder(),
              Stack(
                children: <Widget>[
                  Container(
                    height: kHeight + 20,
                  ),
                  Positioned.fill(
                    top: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                            color: kDefaultColor,
                            borderRadius: BorderRadius.circular(5)),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            'TAGS',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 1.5,
                                color: Colors.white.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: tagList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tagAdder() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                  width: 200,
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
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 25),
                  width: 200,
                  child: TextField(
                    focusNode: focusNode,
                    controller: shortenController,
                    decoration: InputDecoration(
                      hintText: 'Short Name (e.g. t)',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: changeTagColorPressed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: currentColor.value)),
                hoverColor: currentColor.value,
                child: Text(
                  buttonName.value.isEmpty
                      ? 'Change Tag Color'
                      : buttonName.value,
                ),
                color: Colors.white,
                textColor: currentColor.value,
              ),
              GestureDetector(
                onTap: () async => addTagButtonPressed(),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Confirm',
                      style: TextStyle(
                        color: currentColor.value,
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      color: currentColor.value,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tagList() {
    return Observer(builder: (_) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: store.tags.isNotEmpty
            ? ListView.builder(
                itemCount: store.tags.length,
                itemBuilder: (bc, index) {
                  Tag tag = store.tags[index];
                  return TagTile(tag: tag);
                },
              )
            : noTagsText(),
      );
    });
  }

  Widget noTagsText() {
    return Text(
      'No Tag Has Added Yet!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
  // #region LOGIC

  Future addTagButtonPressed() async {
    if (nameController.text.isEmpty) return;
    //DB and STORE
    Tag tag = await TagProvider.db.createTag(
      nameController.text,
      shortenController.text,
      currentColor.value.value,
    );
    MobxStore.st.addTag(tag);

    currentColor.value = Color(kDefaultColor.value);

    buttonName.value = '';

    nameController.text = '';
    shortenController.text = '';
    FocusScope.of(context).unfocus();
  }

  void changeTagColorPressed() {
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
  }
// #endregion

}
