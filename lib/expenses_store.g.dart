// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MobxStore on MobxStoreBase, Store {
  final _$expensesAtom = Atom(name: 'MobxStoreBase.expenses');

  @override
  List<Expense> get expenses {
    _$expensesAtom.reportRead();
    return super.expenses;
  }

  @override
  set expenses(List<Expense> value) {
    _$expensesAtom.reportWrite(value, super.expenses, () {
      super.expenses = value;
    });
  }

  final _$selectedDateExpensesAtom =
      Atom(name: 'MobxStoreBase.selectedDateExpenses');

  @override
  List<Expense> get selectedDateExpenses {
    _$selectedDateExpensesAtom.reportRead();
    return super.selectedDateExpenses;
  }

  @override
  set selectedDateExpenses(List<Expense> value) {
    _$selectedDateExpensesAtom.reportWrite(value, super.selectedDateExpenses,
        () {
      super.selectedDateExpenses = value;
    });
  }

  final _$graphSelectedDateExpensesAtom =
      Atom(name: 'MobxStoreBase.graphSelectedDateExpenses');

  @override
  Map<ViewType, List<Expense>> get graphSelectedDateExpenses {
    _$graphSelectedDateExpensesAtom.reportRead();
    return super.graphSelectedDateExpenses;
  }

  @override
  set graphSelectedDateExpenses(Map<ViewType, List<Expense>> value) {
    _$graphSelectedDateExpensesAtom
        .reportWrite(value, super.graphSelectedDateExpenses, () {
      super.graphSelectedDateExpenses = value;
    });
  }

  final _$graphSelectedDateAtom = Atom(name: 'MobxStoreBase.graphSelectedDate');

  @override
  DateTime get graphSelectedDate {
    _$graphSelectedDateAtom.reportRead();
    return super.graphSelectedDate;
  }

  @override
  set graphSelectedDate(DateTime value) {
    _$graphSelectedDateAtom.reportWrite(value, super.graphSelectedDate, () {
      super.graphSelectedDate = value;
    });
  }

  final _$selectedDateAtom = Atom(name: 'MobxStoreBase.selectedDate');

  @override
  DateTime get selectedDate {
    _$selectedDateAtom.reportRead();
    return super.selectedDate;
  }

  @override
  set selectedDate(DateTime value) {
    _$selectedDateAtom.reportWrite(value, super.selectedDate, () {
      super.selectedDate = value;
    });
  }

  final _$tagsAtom = Atom(name: 'MobxStoreBase.tags');

  @override
  List<Tag> get tags {
    _$tagsAtom.reportRead();
    return super.tags;
  }

  @override
  set tags(List<Tag> value) {
    _$tagsAtom.reportWrite(value, super.tags, () {
      super.tags = value;
    });
  }

  final _$thumbnailExpenseAtom = Atom(name: 'MobxStoreBase.thumbnailExpense');

  @override
  Expense get thumbnailExpense {
    _$thumbnailExpenseAtom.reportRead();
    return super.thumbnailExpense;
  }

  @override
  set thumbnailExpense(Expense value) {
    _$thumbnailExpenseAtom.reportWrite(value, super.thumbnailExpense, () {
      super.thumbnailExpense = value;
    });
  }

  final _$limitMapAtom = Atom(name: 'MobxStoreBase.limitMap');

  @override
  Map<ViewType, double> get limitMap {
    _$limitMapAtom.reportRead();
    return super.limitMap;
  }

  @override
  set limitMap(Map<ViewType, double> value) {
    _$limitMapAtom.reportWrite(value, super.limitMap, () {
      super.limitMap = value;
    });
  }

  final _$isAutomaticAtom = Atom(name: 'MobxStoreBase.isAutomatic');

  @override
  bool get isAutomatic {
    _$isAutomaticAtom.reportRead();
    return super.isAutomatic;
  }

  @override
  set isAutomatic(bool value) {
    _$isAutomaticAtom.reportWrite(value, super.isAutomatic, () {
      super.isAutomatic = value;
    });
  }

  final _$setLimitAsyncAction = AsyncAction('MobxStoreBase.setLimit');

  @override
  Future<void> setLimit(ViewType viewType, double limit, [bool setDatabase]) {
    return _$setLimitAsyncAction
        .run(() => super.setLimit(viewType, limit, setDatabase));
  }

  final _$automaticSetAsyncAction = AsyncAction('MobxStoreBase.automaticSet');

  @override
  Future<void> automaticSet([bool setDatabase]) {
    return _$automaticSetAsyncAction.run(() => super.automaticSet(setDatabase));
  }

  final _$MobxStoreBaseActionController =
      ActionController(name: 'MobxStoreBase');

  @override
  void addExpense(Expense expense) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.addExpense');
    try {
      return super.addExpense(expense);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addAllExpenses(List<Expense> inputExpenses) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.addAllExpenses');
    try {
      return super.addAllExpenses(inputExpenses);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteExpense(Expense expense) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.deleteExpense');
    try {
      return super.deleteExpense(expense);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteAll() {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.deleteAll');
    try {
      return super.deleteAll();
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateExpense(Expense expense) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.updateExpense');
    try {
      return super.updateExpense(expense);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSelectedDate(DateTime inputSelectedDate) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.updateSelectedDate');
    try {
      return super.updateSelectedDate(inputSelectedDate);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addTag(Tag newTag) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.addTag');
    try {
      return super.addTag(newTag);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addAllTags(List<Tag> inputTags) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.addAllTags');
    try {
      return super.addAllTags(inputTags);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteTag(Tag tagToDelete) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.deleteTag');
    try {
      return super.deleteTag(tagToDelete);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteAllTags() {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.deleteAllTags');
    try {
      return super.deleteAllTags();
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateTag(Tag tagToUpdate) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.updateTag');
    try {
      return super.updateTag(tagToUpdate);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Tag searchTag(Tag tagToUpdate) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.searchTag');
    try {
      return super.searchTag(tagToUpdate);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setThumbnailExpense(Expense newExpense) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.setThumbnailExpense');
    try {
      return super.setThumbnailExpense(newExpense);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateGraphSelectedDate(DateTime inputSelectedDate) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.updateGraphSelectedDate');
    try {
      return super.updateGraphSelectedDate(inputSelectedDate);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  double getSelectedDateTotalPrice([DateTime inputSelectedDate]) {
    final _$actionInfo = _$MobxStoreBaseActionController.startAction(
        name: 'MobxStoreBase.getSelectedDateTotalPrice');
    try {
      return super.getSelectedDateTotalPrice(inputSelectedDate);
    } finally {
      _$MobxStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
expenses: ${expenses},
selectedDateExpenses: ${selectedDateExpenses},
graphSelectedDateExpenses: ${graphSelectedDateExpenses},
graphSelectedDate: ${graphSelectedDate},
selectedDate: ${selectedDate},
tags: ${tags},
thumbnailExpense: ${thumbnailExpense},
limitMap: ${limitMap},
isAutomatic: ${isAutomatic}
    ''';
  }
}
