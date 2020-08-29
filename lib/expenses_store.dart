import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:tracker_but_fast/database/expense_provider.dart';
import 'package:tracker_but_fast/database/limit_provider.dart';
import 'package:tracker_but_fast/database/tag_provider.dart';
import 'package:tracker_but_fast/models/tag.dart';
import 'package:tracker_but_fast/models/expense.dart';
import 'package:tracker_but_fast/pages/graphPage.dart';

part 'expenses_store.g.dart';

class MobxStore extends MobxStoreBase with _$MobxStore {
  static final MobxStore st = MobxStore._();

  MobxStore._();
}

abstract class MobxStoreBase with Store {
  // #region VARIABLES
  @observable
  List<Expense> expenses = new List<Expense>();
  @observable
  List<Expense> selectedDateExpenses = new List<Expense>();
  @observable
  Map<ViewType, List<Expense>> graphSelectedDateExpenses = new Map();
  @observable
  DateTime graphSelectedDate;
  @observable
  DateTime selectedDate;
  @observable
  List<Tag> tags = new List<Tag>();
  @observable
  Tag editTag;
  @observable
  Expense thumbnailExpense = new Expense();
  @observable
  Map<ViewType, double> limitMap = new Map();
  @observable
  bool isAutomatic;
  @observable
  bool isUseLimit;
  // #endregion

  //
  //  EXPENSE SECTION
  //
  // #region EXPENSE

  @action
  void addExpense(Expense expense) {
    print('STORE:\t expense added ${expense.name}');
    expenses.add(expense);
    if (isSelectedDate(expense, selectedDate))
      selectedDateExpenses = [...selectedDateExpenses, expense];
  }

  @action
  void addAllExpenses(List<Expense> inputExpenses) {
    expenses.addAll(inputExpenses);
    inputExpenses.forEach((expense) {
      if (isSelectedDate(expense, selectedDate))
        selectedDateExpenses = [...selectedDateExpenses, expense];
    });
    print('STORE:\t expenses added $expenses');
  }

  @action
  void deleteExpense(Expense expense) {
    // expenses.removeWhere((element) => element.id == expense.id);
    expenses = expenses.where((e) => e.id != expense.id).toList();

    if (isSelectedDate(expense, selectedDate))
      selectedDateExpenses = selectedDateExpenses
          .where((element) => element.id != expense.id)
          .toList();
    print('STORE:\texpense deleted ${expense.name}');
  }

  @action
  void deleteAll() {
    expenses = [];
    selectedDateExpenses = [];
  }

  @action
  void updateExpense(Expense expense) {
    expenses = expenses.map((e) {
      if (e.id == expense.id) return expense;
      return e;
    }).toList();

    selectedDateExpenses = selectedDateExpenses.map((e) {
      updateSelectedDate(selectedDate);
      if (e.id == expense.id) return expense;
      return e;
    }).toList();

    print('STORE:\texpense updated ${expense.name}');
  }

  @action
  void updateSelectedDate(DateTime inputSelectedDate) {
    selectedDate = inputSelectedDate;

    selectedDateExpenses = expenses
            ?.where((expense) => isSelectedDate(expense, inputSelectedDate))
            ?.toList() ??
        [];

    print(
        'STORE:\tselectedDateUpdated. selectedDateExpenses ==> ${selectedDateExpenses.map((e) => e.name).join(' ')}');
  }

// #endregion

  //
  //  TAGS SECTION
  //
// #region TAG

  @action
  void addTag(Tag newTag) {
    var foundTag = searchTag(newTag);
    if (foundTag != null) {
      newTag.id = foundTag.id;
      updateTag(newTag);
    } else {
      tags.add(newTag);
    }

    for (var expense in expenses) {
      var tags = expense.tags;
      expense.tags = tags.map((tag) {
        if (tag.name == newTag.name) return newTag;
        return tag;
      }).toList();
      if (expense.tags.any((tag) => tag.name == newTag.name)) {
        updateExpense(expense);
        // ExpenseProvider.db.update(expense);
      }
    }

    print('STORE:\ttag added ${newTag.name}');
  }

  @action
  void addAllTags(List<Tag> inputTags) {
    tags.addAll(inputTags);
  }

  @action
  Future<void> deleteTag(Tag tagToDelete, {bool setDatabase = false}) async {
    tags = tags.where((e) => e.id != tagToDelete.id).toList();

    var expensesNeedUpdate = [];
    //edit expenses if there is a expense that have a [tagToDelete]
    expenses = expenses.fold([], (list, exp) {
      if (exp.tags.contains(tagToDelete)) {
        exp.tags = exp.tags.where((tag) => tag != tagToDelete).toList();
        expensesNeedUpdate.add(exp);
      }
      return [...list, exp];
    });
    for (final exp in expensesNeedUpdate) {
      await ExpenseProvider.db.update(exp);
    }

    if (setDatabase) TagProvider.db.delete(tagToDelete);

    print('STORE:\ttag deleted ${tagToDelete.name}');
  }

  @action
  void deleteAllTags() {
    tags = [];
  }

  @action
  void updateTag(Tag tagToUpdate, {bool setDatabase = false}) {
    tags = tags.map((e) {
      if (e.id == tagToUpdate.id) return tagToUpdate;
      return e;
    }).toList();
    for (var expense in expenses) {
      var tags = expense.tags;
      expense.tags = tags.map((tag) {
        if (tag.name == tagToUpdate.name) return tagToUpdate;
        return tag;
      }).toList();
      if (expense.tags.any((tag) => tag.name == tagToUpdate.name)) {
        updateExpense(expense);
        ExpenseProvider.db.update(expense);
      }
    }
    if (setDatabase) TagProvider.db.update(tagToUpdate);
  }

  @action
  Tag searchTag(Tag tagToUpdate) {
    final oldTag = tags
        .where((element) {
          return element.name == tagToUpdate.name ||
              element.shorten == tagToUpdate.shorten;
        })
        .toList()
        .asMap()[0];
    if (oldTag?.name != null) print('STORE:\tfound tag ${oldTag?.name}');
    return oldTag;
  }

  Tag getTagByName(String name) {
    var found = tags
        .where(
          (element) => element.name == name || element.shorten == name,
        )
        .toList();
    if (found.isEmpty) return null;
    return found[0];
  }

  @action
  setThumbnailExpense(Expense newExpense) {
    thumbnailExpense = newExpense;
  }
// #endregion

  //
  //  GRAPH SECTION
  //
  // #region GRAPH
  @action
  void updateGraphSelectedDate(DateTime inputSelectedDate) {
    selectedDate = DateTime.parse(selectedDate.toIso8601String());
    graphSelectedDate = inputSelectedDate;
    graphSelectedDateExpenses[ViewType.Day] = expenses
        .where(
          (element) => isSelectedDate(element, graphSelectedDate),
        )
        .toList();
    graphSelectedDateExpenses[ViewType.Week] = expenses
        .where(
          (element) =>
              weekNumber(element.date) == weekNumber(graphSelectedDate) &&
              element.date.year == graphSelectedDate.year,
        )
        .toList();
    graphSelectedDateExpenses[ViewType.Month] = expenses
        .where(
          (element) =>
              element.date.month == graphSelectedDate.month &&
              element.date.year == graphSelectedDate.year,
        )
        .toList();

    print('STORE:\t graph selected date updated. $graphSelectedDate');
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  @action
  double getSelectedDateTotalPrice([DateTime inputSelectedDate]) {
    return expenses.fold(0, (prev, expense) {
      //todo add lsmit
      if (inputSelectedDate == null && selectedDate == null)
        inputSelectedDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
      if (isSelectedDate(expense, inputSelectedDate ?? selectedDate))
        return prev + expense.getTotalExpense();
      return prev;
    });
  }

  Map<Tag, double> getTagTotalGraph(List<Expense> expenses) {
    Map<Tag, double> rv = Map();
    for (var expense in expenses) {
      expense.tags.forEach((tag) {
        rv[tag] ??= 0;
        rv[tag] += expense.getTotalExpense();
      });
    }
    return rv;
  }

  // #endregion

  //
  //  LIMIT SECTION
  //
  // #region LIMIT
  @action
  Future<void> setLimit(ViewType viewType, double limit,
      {bool setDatabase = false}) async {
    var newmap = limitMap;
    newmap[viewType] = limit;
    limitMap = newmap;
    if (setDatabase) await LimitProvider.db.updateLimit(limitMap);
  }

  @action
  Future<void> automaticSet({bool setDatabase = false}) async {
    final monthly = limitMap[ViewType.Month];
    setLimit(
      ViewType.Day,
      double.parse((monthly / 30).toStringAsFixed(2)),
    );
    setLimit(
      ViewType.Week,
      double.parse((monthly / 30 * 7).toStringAsFixed(2)),
    );
    if (setDatabase) {
      await LimitProvider.db.updateLimit(limitMap);
      LimitProvider.db.updateIsAutomatic(isAutomatic);
    }
  }

  @action
  Future<void> setUseLimit(bool inputUseLimit,
      {bool setDatabase = false}) async {
    isUseLimit = inputUseLimit;
    if (setDatabase) {
      await LimitProvider.db.updateUseLimit(isUseLimit);
    }
  }
  //#endregion

  // #region HELPER FUNCTIONS
  bool isSelectedDate(Expense exp, [DateTime dateInput]) {
    if (dateInput == null)
      dateInput ??= selectedDate ??
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          );
    return exp.date.year == dateInput.year &&
        exp.date.month == dateInput.month &&
        exp.date.day == dateInput.day;
  }
  // #endregion

}
