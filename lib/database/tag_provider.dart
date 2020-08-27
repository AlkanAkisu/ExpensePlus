import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:tracker_but_fast/models/tag.dart';

class TagProvider {
  static Database _database;
  static final TagProvider db = TagProvider._();

  TagProvider._();

  static const String TAG_STORE_NAME = 'tags';
  final _tagStore = intMapStoreFactory.store(TAG_STORE_NAME);

  Future<Database> get database async {
    if (_database != null) return _database;

    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, 'tag_database.db');
    // open the database
    _database = await databaseFactoryIo.openDatabase(dbPath);

    return _database;
  }

  /// Insert expense on database and returns as int
  Future<Tag> createTag(String name, String shorten, int hexCode) async {
    if (shorten.isEmpty) shorten = name;
    Tag newTag = new Tag(
      name: name,
      shorten: shorten,
      color: Color(hexCode),
      hexCode: hexCode,
    );
    //look for same name or shorten
    final map = (await Future.wait([
      searchTag(name),
      searchTag(shorten),
    ]))
        .asMap();

    var oldTag = map[0] ?? map[1];

    if (oldTag != null) {
      newTag.id = oldTag.id;
      await update(newTag);
    } else {
      int key = await addTag(newTag);
      newTag.id = key;
    }
    return newTag;
  }

  Future<int> addTag(Tag newTag) async {
    var key = await _tagStore.add(
      await database,
      newTag.toJson(),
    );
    newTag.id = key;
    update(newTag);
    print('DATABASE:\ttag added ${newTag.name}');
    return key;
  }

  Future update(Tag newTag) async {
    _tagStore.record(newTag.id).update(await database, newTag.toJson());
    print('DATABASE:\t tag updated $newTag');
  }

  Future delete(Tag newTag) async {
    await _tagStore.delete(await database,
        finder: Finder(
          filter: Filter.byKey(newTag.id),
        ));

    await getAllTags().then(
      (value) => print('DATABASE:\ttag deleted => $value'),
    );
  }

  Future deleteAll() async {
    await _tagStore.delete(
      await database,
    );
    print('DATABASE:\tall tags deleted');
  }

  Future<List<Tag>> getAllTags() async {
    final records = await _tagStore.find(
      await database,
    );
    if (records.isEmpty) return [];
    List<Tag> rv = records.map(
      (record) {
        Tag tag = Tag.fromJson(record.value);
        tag.id = record.key;
        return tag;
      },
    ).toList();
    return rv; //change it
  }

  Future<Tag> searchTag(String str) async {
    final tags = await getAllTags();
    // print('DATABASE:\t tags = $tags\t str = $str');
    if (tags == null) return null;
    return tags
        .where(
          (element) => element.name == str || element.shorten == str,
        )
        .toList()
        .asMap()[0];
  }
}
