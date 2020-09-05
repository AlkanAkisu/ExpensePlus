import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:expensePlus/pages/graphPage.dart';

class SettingsProvider {
  var needsUpdate = false;

  static Database _database;
  static final SettingsProvider db = SettingsProvider._();

  SettingsProvider._();

  static const String SETTINGS_STORE_NAME = 'settings';
  final _settingsStore = intMapStoreFactory.store(SETTINGS_STORE_NAME);

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
    await _settingsStore.record(0).put(
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
    final val = await _settingsStore.record(0).get(
          await database,
        );

    if (val == null) {
      await updateLimit({
        ViewType.Day: null,
        ViewType.Week: null,
        ViewType.Month: null,
      });
      return <ViewType, double>{
        ViewType.Day: null,
        ViewType.Week: null,
        ViewType.Month: null,
      };
    }

    return <ViewType, double>{
      ViewType.Day: val['day'],
      ViewType.Week: val['week'],
      ViewType.Month: val['month'],
    };
  }

  Future<void> updateIsAutomatic(bool isAutomatic) async {
    await _settingsStore.record(1).put(
      await database,
      {
        'isAutomatic': isAutomatic,
      },
    );
  }

  Future<bool> getIsAutomatic() async {
    final val = await _settingsStore.record(1).get(
          await database,
        );
    if (val == null) {
      await updateIsAutomatic(true);
      return true;
    }
    return val['isAutomatic'];
  }

  //USE LIMIT
  Future<void> updateUseLimit(bool useLimit) async {
    await _settingsStore.record(2).put(
      await database,
      {
        'useLimit': useLimit,
      },
    );
  }

  Future<bool> getUseLimit() async {
    final val = await _settingsStore.record(2).get(
          await database,
        );

    if (val == null) {
      await updateUseLimit(false);
      return false;
    }
    return val['useLimit'];
  }

  Future<bool> isFirstTime() async {
    final val = await _settingsStore.record(3).get(
          await database,
        );

    if (val == null) {
      await _settingsStore.record(3).put(
        await database,
        {
          'firstTime': false,
        },
      );
      return true;
    }
    return false;
  }

  Future<void> resetFirstTime() async {
    await _settingsStore.record(3).delete(
          await database,
        );
  }

  Future<String> getDateStyle() async {
    final val = await _settingsStore.record(4).get(
          await database,
        );

    if (val == null) {
      await _settingsStore.record(4).put(
        await database,
        {
          'dateStyle': 'dd/mm',
        },
      );
      return 'dd/mm';
    }
    return val['dateStyle'];
  }

  Future<void> changeDateStyle(String style) async {
    await _settingsStore.record(4).update(
      await database,
      {
        'dateStyle': '$style',
      },
    );
  }
}
