import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tracker_but_fast/models/expense.dart';
import 'package:tracker_but_fast/models/tag.dart';

class ExpenseProvider {
  var needsUpdate = false;

  static Database _database;
  static final ExpenseProvider db = ExpenseProvider._();

  ExpenseProvider._();

  static const String EXPENSES_STORE_NAME = 'expenses';
  final _expenseStore = intMapStoreFactory.store(EXPENSES_STORE_NAME);

  Future<Database> get database async {
    if (_database != null) return _database;

    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'expense_database.db');
    // open the database
    _database = await databaseFactoryIo.openDatabase(dbPath);

    return _database;
  }

  /// Insert expense on database and returns as int
  Future<int> createExpense(Expense newExpense) async {
    var key = await _expenseStore.add(
      await database,
      newExpense.toJson(),
    );
    newExpense.id = key;
    update(newExpense);
    print('DATABASE:\texpense added ${newExpense.name}');
    return key;
  }

  Future update(Expense newExpense) async {
    _expenseStore
        .record(newExpense.id)
        .update(await database, newExpense.toJson());
    print('DATABASE:\texpense updated ');
  }

  Future updateTags(Tag tag) async {
    var records = await _expenseStore.find(await database);

    for (var record in records) {
      var exp = Expense.fromJson(record.value);
      exp.tags = exp.tags.map((e) {
        if (tag.name == tag.name) {
          needsUpdate = true;
          return tag;
        }
        return tag;
      }).toList();
      update(exp);
    }
  }

  Future delete(Expense newExpense) async {
    await _expenseStore.delete(await database,
        finder: Finder(
          filter: Filter.byKey(newExpense.id),
        ));

    await getAllExpenses().then(
      (value) => print('DATABASE:\texpense deleted => $value'),
    );
  }

  Future deleteAll() async {
    await _expenseStore.delete(
      await database,
    );
    print('DATABASE:\tall expenses deleted');
  }

  Future<List<Expense>> getAllExpenses() async {
    final records = await _expenseStore.find(
      await database,
    );
    if (records.isEmpty) return [];
    List<Expense> rv = records.map(
      (record) {
        Expense exp = Expense.fromJson(record.value);
        exp.id = record.key;
        return exp;
      },
    ).toList();
    return rv;
  }
}
