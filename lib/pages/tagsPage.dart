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
  ValueNotifier<String> conflict, confirmButtonName;

  @override
  Widget build(BuildContext context) {
    if (fToast == null) fToast = new FToast(context);
    currentColor = useState(Color(kDefaultColor.value));
    this.context = context;
    double kHeight = 40.0;

    buttonName = useState('');
    conflict = useState(null);
    confirmButtonName = useState('Add');

  

    useEffect(() {
      store.editTag = null;
      nameController.text = '';
      shortenController.text = '';
      return () {};
    }, []);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
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
                  height: store.tags.isNotEmpty ? null : 0,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Text(
                    'Hint: Swipe Right To Edit, Left To Delete And Click A Tag for more info',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                  ),
                ),
                tagList(),
              ],
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
        const double kSize = 40;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
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
                    child: Text('Change Tag Color'),
                    color: Colors.white,
                    textColor: currentColor.value,
                  ),
                  FlatButton(
                    color: conflict.value != null
                        ? Colors.grey
                        : currentColor.value.withOpacity(0.1),
                    onPressed: conflict.value != null
                        ? null
                        : () async => await addTagButtonPressed(),
                    splashColor: currentColor.value.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      child: Row(
                        children: <Widget>[
                          Text(
                            confirmButtonName.value ?? 'Add',
                            style: TextStyle(
                              color: conflict.value != null
                                  ? Colors.grey
                                  : currentColor.value,
                            ),
                          ),
                          Icon(
                            Icons.check_circle_outline,
                            color: conflict.value != null
                                ? Colors.grey
                                : currentColor.value,
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
                      constraints: BoxConstraints(
                        maxHeight: kSize,
                        maxWidth: kSize,
                      ),
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
              SizedBox(height: buttonName.value.isEmpty ? 0 : 15),
              buttonName.value.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Preview:'),
                        SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 6),
                          margin: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: currentColor.value,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                )
                              ],
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: currentColor.value,
                                width: 1,
                              )),
                          child: Text(
                            buttonName.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: currentColor.value,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: buttonName.value.isEmpty ? 20 : 10),
            ],
          ),
        );
      },
    );
  }

  Widget tagList() {
    return Observer(builder: (_) {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 250),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: store.tags.isEmpty
              ? noTagsText()
              : Column(
                  children: store.tags
                      .map((tag) => TagTile(
                            tag: tag,
                            editButtonCallback: editButtonPressed,
                          ))
                      .toList(),
                ),
        ),
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

  conflictChecker(String str) {
    var name = store.getTagByName(str)?.name;
    bool isEditing = store.editTag != null,
        isFoundAnotherOnStore = name != null && store.editTag?.name != name,
        isConflict = conflict.value != null;

    if (isEditing && isFoundAnotherOnStore)
      //conflict when updating
      conflict.value = name;
    else if (!isEditing && isFoundAnotherOnStore)
      //conflict when adding
      conflict.value = name;
    else if (isConflict)
      //check if value changed
      conflict.value = null;

    //check if value changed
    String oldVal = confirmButtonName.value;
    String newVal;
    if (conflict.value != null)
      newVal = 'Conflict';
    else if (isEditing)
      newVal = 'Update';
    else
      newVal = 'Add';
    if (oldVal != newVal) {
      confirmButtonName.value = newVal;
    }
  }

  // #region LOGIC

  Future addTagButtonPressed() async {
    if (conflict.value != null) return;
    if (nameController.text.isEmpty) return;
    //DB and STORE
    Tag tag;
    String msg = 'Tag has been added';
    Color color = Colors.green[400];
    bool update = false;

    if (conflict.value != null || store.editTag != null) {
      msg = 'Tag has been updated';
      color = Colors.blue[400];
      update = true;
    }
    if (!update)
      tag = await TagProvider.db.createTag(
        nameController.text,
        shortenController.text,
        currentColor.value.value,
      );
    else
      tag = new Tag(
        name: nameController.text,
        shorten: shortenController.text,
        hexCode: currentColor.value.value,
      );

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (update) {
      tag.id = store.editTag.id;
      MobxStore.st.updateTag(tag, setDatabase: true);
    } else {
      MobxStore.st.addTag(tag);
    }

    store.editTag = null;

    confirmButtonName.value = 'Add';

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
    confirmButtonName.value = 'Update';
  }

  editCancelPressed() {
    nameController.text = '';
    shortenController.text = '';
    currentColor.value = kDefaultColor;
    buttonName.value = '';
    confirmButtonName.value = 'Add';
    store.editTag = null;
  }
// #endregion

}
