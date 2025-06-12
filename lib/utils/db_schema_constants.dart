class BaseColumns {}

class ChatHistoryEntry extends BaseColumns {
  static const String chatHistoryTable = "chat_history_table";
  static const String userId = "user_id";
  static const String sessionId = "session_id";
  static const String senderType = "sender_type";
  static const String message = "message";
  static const String insertTs = "insert_ts";

  static const String createTableQuery = ''' CREATE TABLE $chatHistoryTable (
      $userId TEXT,
      $sessionId TEXT,
      $senderType TEXT,
      $message TEXT,
      $insertTs INTEGER,
      PRIMARY KEY ($userId, $sessionId ,$insertTs)
    )''';

  static const String deleteChatHistoryTable =
      "DROP TABLE IF EXISTS $chatHistoryTable";

  static const String primaryKeyString = "$userId = ? AND $sessionId = ?";
  static const String insertDataClause =
      "$userId = ? AND $sessionId = ? AND $insertTs = ?";

}
