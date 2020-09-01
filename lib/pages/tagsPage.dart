import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expensePlus/database/tag_provider.dart';
import 'package:expensePlus/expenses_store.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expensePlus/models/tag.dart';
import 'package:expensePlus/widgets/tagTile.dart';

class TagsPage extends HookWidget {
  BuildContext context;
  ValueNotifier<Color> currentColor;
  ValueNotifier<String> buttonName;
  TextEditingController nameController = new TextEditingController();
  TextEditingController shortenController = new TextEditingController();
  final store = MobxStore.st;
  FocusNode focusNode;
  final Color kDefaultColor = Colors.blue[500];
  FToast fToast;
  String conflict, confirmButtonName = 'Add';

  @override
  Widget build(BuildContext context) {
    if (fToast == null) fToast = new FToast(context);
    currentColor = useState(Color(kDefaultColor.value));
    buttonName = useState('Change Tag Color');
    this.context = context;
    double kHeight = 40.0;

    useEffect(
        () => () {
              store.editTag = null;
              nameController.text = '';
              shortenController.text = '';
            },
        []);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Color(0xfff9f9f9),
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
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      'Hint: Swipe Right To Edit, Left To Delete And Click A Tag for more info',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w100),
                    ),
                  ),
                  Expanded(
                    child: tagList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tagAdder() {
    return Observer(
      builder: (_) {
        store.editTag;
        store.tags;

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
                          conflictChecker(str);
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
                        onChanged: (str) {
                          conflictChecker(str);
                        },
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
                  FlatButton(
                    color: currentColor.value.withOpacity(0.1),
                    onPressed: () async => addTagButtonPressed(),
                    splashColor: currentColor.value.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      child: Row(
                        children: <Widget>[
                          Text(
                            confirmButtonName ?? 'Add',
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
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: store.editTag != null ? null : 0,
                    child: IconButton(
                      onPressed: editCancelPressed,
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      highlightColor: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              conflictText(),
            ],
          ),
        );
      },
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
                  return TagTile(
                    tag: tag,
                    editButtonCallback: editButtonPressed,
                  );
                },
              )
            : noTagsText(),
      );
    });
  }

  Widget noTagsText() {
    return Text(
      'No Tag Has Been Added Yet!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget conflictText() {
    String name = nameController.text;
    String short = shortenController.text;

    //editing bug fix
    if (store.editTag == null) {
      conflict = null;
      conflict = (store.getTagByName(name) ?? store.getTagByName(short))?.name;
    }

    if (conflict == null) return Container();
    return Container(
      child: Text(
        'Conflict on $conflict',
      ),
    );
  }

  conflictChecker(String str) {
    conflict = null;
    var name = store.getTagByName(str)?.name;
    if (store.editTag != null && name != null) {
      if (name != store.editTag.name) {
        conflict = name;
      }
    } else if (store.editTag == null) conflict = name;

    confirmButtonName = 'Add';
    if (conflict != null || store.editTag != null) {
      confirmButtonName = 'Update';
    }
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
    String msg = 'Tag has been added';
    Color color = Colors.green[400];
    bool update = false;

    if (conflict != null || store.editTag != null) {
      msg = 'Tag has been updated';
      color = Colors.blue[400];
      update = true;
    }

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (conflict != null && store.editTag != null) {
      tag.id = store.getTagByName(conflict).id;
      MobxStore.st.updateTag(tag, setDatabase: true);
      MobxStore.st.deleteTag(store.editTag, setDatabase: true);
    } else if (update) {
      tag.id = store.editTag?.id ??
          store.getTagByName(nameController.text)?.id ??
          store.getTagByName(shortenController.text)?.id;
      MobxStore.st.updateTag(tag);
    } else {
      MobxStore.st.addTag(tag);
    }

    store.editTag = null;

    confirmButtonName = 'Add';

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

  editButtonPressed() {
    nameController.text = store.editTag.name;
    shortenController.text = store.editTag.shorten;
    currentColor.value = store.editTag.color;
    buttonName.value = store.editTag.name;
    confirmButtonName = 'Update';
  }

  editCancelPressed() {
    print('edit cancel');
    nameController.text = '';
    shortenController.text = '';
    currentColor.value = kDefaultColor;
    buttonName.value = '';
    confirmButtonName = 'Add';
    store.editTag = null;
  }
// #endregion

}
