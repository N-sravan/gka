import 'package:gka/utils/db_schema_constants.dart';

class ChatHistoryTable {
  late String _userId;
  late String _sessionId;
  late String _isUser;
  late String _message;
  late int _insertTs;

  ChatHistoryTable(this._userId, this._sessionId, this._isUser,
      this._message, this._insertTs);

  // Convert a UserMetaEntry object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[ChatHistoryEntry.userId] = _userId;
    map[ChatHistoryEntry.sessionId] = _sessionId;
    map[ChatHistoryEntry.senderType] = _isUser;
    map[ChatHistoryEntry.message] = _message;
    map[ChatHistoryEntry.insertTs] = _insertTs;
    return map;
  }

  // Extract a config object from a Map object
  ChatHistoryTable.fromMapObject(Map<String, dynamic>? map) {
    _userId = map![ChatHistoryEntry.userId];
    _sessionId = map[ChatHistoryEntry.sessionId];
    _isUser = map[ChatHistoryEntry.senderType];
    _message = map[ChatHistoryEntry.message];
    _insertTs = map[ChatHistoryEntry.insertTs];
  }

  ChatHistoryTable.fromJson(Map<String, dynamic> parsedJson) {
    print("ChatHistoryTable $parsedJson");
    _userId = parsedJson['userid'];
    _sessionId = parsedJson['sessionid'];
    _isUser = parsedJson['sendertype'];
    _message = parsedJson['message'];
    _insertTs = parsedJson['insertts'];
  }
}
