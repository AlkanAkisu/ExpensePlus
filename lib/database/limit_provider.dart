import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tracker_but_fast/pages/graphPage.dart';

class LimitProvider {
  var needsUpdate = false;

  static Database _database;
  static final LimitProvider db = LimitProvider._();

  LimitProvider._();

  static const String LIMIT_STORE_NAME = 'limit';
  final _limitStore = intMapStoreFactory.store(LIMIT_STORE_NAME);

  Future<Database> get database async {
    if (_database != null) return _database;

    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'limit_database.db');
    // open the database
    _database = await databaseFactoryIo.openDatabase(dbPath);

    return _database;
  }

  /// Insert limit on database and returns as int
  Future<void> updateLimit(Map<ViewType, double> limitMap) async {
    await _limitStore.record(0).put(
      await database,
      {
        'day': limitMap[ViewType.Day],
        'week': limitMap[ViewType.Week],
        'month': limitMap[ViewType.Month],
      },
    );
  }

  /// Insert limit on database and returns as int
  Future<Map<ViewType, double>> getLimit() async {
    final val = await _limitStore.record(0).get(
          await database,
        );

    if (val == null)
      await updateLimit({
        ViewType.Day: null,
        ViewType.Week: null,
        ViewType.Month: null,
      });

    Map<ViewType, double> rv = {
      ViewType.Day: val['day'],
      ViewType.Week: val['week'],
      ViewType.Month: val['month'],
    };
    print(rv);
    return rv;
  }

  Future<void> updateIsAutomatic(bool isAutomatic) async {
    await _limitStore.record(1).put(
      await database,
      {
        'isAutomatic': isAutomatic,
      },
    );
  }

  Future<bool> getIsAutomatic() async {
    final val = await _limitStore.record(1).get(
          await database,
        );
    if (val == null) return null;
    return val['isAutomatic'];
  }
}
