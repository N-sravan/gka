import 'package:gka/chat/model/chat_history_table.dart';
import 'package:gka/chat/model/offline_chat_history_model.dart';
import 'package:gka/utils/db_schema_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:gka/utils/common_constants.dart' as constants;

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    _database ??= await _initializeDatabase();
    print("database initialized");
    return _database;
  }

  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, constants.dbName);

    //open/create database at a given path
    var uniappDatabase = await openDatabase(path,
        version: constants.dbVersion,
        onCreate: _createDb,
        onUpgrade: _upgradeDb,
        onDowngrade: _onDowngrade);

    return uniappDatabase;
  }

  //for creating db
  void _createDb(Database db, int newVersion) async {
    Batch batch = db.batch();
    batch.execute(ChatHistoryEntry.createTableQuery);
    await batch.commit();
  }

//for upgrading db
  void _upgradeDb(Database db, int newVersion, int oldVersion) async {
    Batch batch = db.batch();
    batch.execute(ChatHistoryEntry.deleteChatHistoryTable);
    await batch.commit();

    // Create new tables
    _createDb(db, newVersion);
  }

//for downgrade db
  void _onDowngrade(Database db, int oldVersion, int newVersion) {
    _upgradeDb(db, oldVersion, newVersion);
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getChatHistoryList(
      String? userId, String? sessionId) async {
    Database? db = await database;
    String whereString = '${ChatHistoryEntry.userId} = ? AND '
        '${ChatHistoryEntry.sessionId} = ?';
    List<dynamic> whereArguments = [userId, sessionId];
    var result = await db!.query(ChatHistoryEntry.chatHistoryTable,
        where: whereString, whereArgs: whereArguments);
    return result;
  }

  Future<bool> insertChatData(
    Map<String, List<OfflineChatModel>> sessionIdHistoryMapping,
    String userId,
  ) async {
    Database? db = await this.database;
    int count = 0;

    final updateBatch = db!.batch();

    List<_InsertTask> insertTasks = [];

    // Sort and prepare update batch
    sessionIdHistoryMapping.forEach((sessionId, chatModelList) {
      chatModelList.sort((a, b) => a.insertTs.compareTo(b.insertTs));

      for (OfflineChatModel model in chatModelList) {
        List<dynamic> whereArguments = [
          userId,
          sessionId,
          model.insertTs,
        ];

        Map<String, dynamic> map = model.toMap();
        map['user_id'] = userId;
        map['session_id'] = sessionId;

        updateBatch.update(
          ChatHistoryEntry.chatHistoryTable,
          map,
          where: ChatHistoryEntry.insertDataClause,
          whereArgs: whereArguments,
        );

        insertTasks.add(_InsertTask(map: map, whereArgs: whereArguments));
      }
    });

    List<dynamic> updateResults = await updateBatch.commit();
    print('Update results: $updateResults');

    final insertBatch = db.batch();

    for (int i = 0; i < insertTasks.length; i++) {
      if (updateResults[i] == 0) {
        insertBatch.insert(
          ChatHistoryEntry.chatHistoryTable,
          insertTasks[i].map);
        count++;
      }
    }
    print("Inserting ${count} new rows...");
    await insertBatch.commit();
    print("Insert batch committed.");

    return true;
  }
}

class _InsertTask {
  final Map<String, dynamic> map;
  final List<dynamic> whereArgs;

  _InsertTask({required this.map, required this.whereArgs});
}
