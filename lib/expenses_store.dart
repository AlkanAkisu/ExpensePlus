import 'package:mobx/mobx.dart';
import 'package:tracker_but_fast/models/tag.dart';
import 'package:tracker_but_fast/models/expense.dart';

part 'expenses_store.g.dart';

class MobxStore = MobxStoreBase with _$MobxStore;

abstract class MobxStoreBase with Store {
  @observable
  List<Expense> expenses = new List<Expense>();
  @observable
  List<Expense> selectedDateExpenses = new List<Expense>();
  @observable
  DateTime selectedDate;
  @observable
  List<Tag> tags = new List<Tag>();
  @observable
  Expense thumbnailExpense = new Expense();

  @action
  void addExpense(Expense expense) {
    print('STORE:\t expense added ${expense.name}');
    expenses.add(expense);
    if (isSelectedDate(expense)) selectedDateExpenses.add(expense);
  }

  @action
  void addAllExpenses(List<Expense> inputExpenses) {
    expenses.addAll(inputExpenses);
    inputExpenses.forEach((expense) {
      if (isSelectedDate(expense)) selectedDateExpenses.add(expense);
    });
  }

  @action
  void deleteExpense(Expense expense) {
    expenses.removeWhere((element) => element.id == expense.id);
    if (isSelectedDate(expense))
      selectedDateExpenses.removeWhere((element) => element.id == expense.id);
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
    updateSelectedDate(selectedDate);
    print('STORE:\texpense updated ${expense.name}');
  }

  @action
  void updateSelectedDate(DateTime inputSelectedDate) {
    selectedDate = inputSelectedDate;
    selectedDateExpenses = expenses?.where(isSelectedDate)?.toList();
    selectedDateExpenses ??= [];
    print(
        'STORE:\tselectedDateUpdated. selectedDateExpenses ==> $selectedDateExpenses');
  }

  //TAGS
  @action
  void addTag(Tag newTag) {
    if (searchTag(newTag) != null) {
      newTag.id = searchTag(newTag).id;
      updateTag(newTag);
    } else {
      tags.add(newTag);
    }
    //TODO debug it
    // for (var expense in expenses) {
    //   var tags = expense.tags;
    //   expense.tags = tags.map((e) {
    //     if (e.name == newTag.name || e.shorten == newTag.shorten) {
    //       return newTag;
    //     }
    //     return e;
    //   }).toList();
    //   updateExpense(expense);
    // }
    print('STORE:\ttag added ${newTag.name}');
  }

  @action
  void addAllTags(List<Tag> inputTags) {
    tags.addAll(inputTags);
  }

  @action
  void deleteTag(Tag tagToDelete) {
    tags.removeWhere((element) => element.id == tagToDelete.id);

    print('STORE:\ttag deleted ${tagToDelete.name}');
  }

  @action
  void deleteAllTags() {
    tags = [];
  }

  @action
  void updateTag(Tag tagToUpdate) {
    tags = tags.map((e) {
      if (e.id == tagToUpdate.id) return tagToUpdate;
      return e;
    }).toList();

    print('STORE:\tupdated tag ${tagToUpdate.name}');
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

    print('STORE:\found tag ${oldTag?.name}');
    return oldTag;
  }

  @action
  setThumbnailExpense(Expense newExpense) {
    thumbnailExpense = newExpense;
  }

  //HELPER FUNCTIONS
  bool isSelectedDate(Expense exp) {
    return exp.date.year == selectedDate.year &&
        exp.date.month == selectedDate.month &&
        exp.date.day == selectedDate.day;
  }
}
