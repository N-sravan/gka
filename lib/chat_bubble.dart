import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gka/utils/app_state.dart';
import 'package:intl/intl.dart';
import 'package:gka/utils/common_constants.dart' as constants;

class ChatBubble extends StatefulWidget {
  const ChatBubble(
      {Key? key,
      required this.text,
      required this.isUser,
      required this.logMessage,
      this.imageUrl,
      this.tableColumnData,
      this.tableRowData,
      this.errorLog,
      required this.hasErrorLog,
      this.timestampMapping,
      this.sessionId})
      : super(key: key);

  final String text;
  final bool isUser;
  final String? imageUrl;
  final List<dynamic>? tableColumnData;
  final List<dynamic>? tableRowData;
  final String logMessage;
  final String? errorLog;
  final bool hasErrorLog;
  final Map<String, String>? timestampMapping;
  final String? sessionId;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasContent = (widget.imageUrl!.isNotEmpty ||
        (widget.tableColumnData != null &&
            widget.tableColumnData!.isNotEmpty &&
            widget.tableRowData != null &&
            widget.tableRowData!.isNotEmpty) ||
        widget.text.isNotEmpty);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.isUser ? 64.0 : 16.0,
        4,
        widget.isUser ? 16.0 : 2.0,
        4,
      ),
      child: Align(
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
              widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isUser &&
                (widget.hasErrorLog != null && !widget.hasErrorLog))
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/vani.png')),
                ),
              ),
            if (hasContent)
              Flexible(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: !widget.isUser ? Colors.white : Colors.green[400],
                    borderRadius: widget.isUser
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          )
                        : const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.imageUrl != null &&
                            widget.imageUrl!.isNotEmpty)
                          _imageView(),
                        if (widget.tableColumnData != null &&
                            widget.tableColumnData!.isNotEmpty &&
                            widget.tableRowData != null &&
                            widget.tableRowData!.isNotEmpty)
                          _tableView(),
                        const SizedBox(height: 10),
                        if (widget.text.isNotEmpty) _textView(),
                      ],
                    ),
                  ),
                ),
              ),
            if (!widget.isUser && widget.logMessage.isNotEmpty) _infoView(),
            if (widget.isUser) _userProfileView(),
            if (widget.hasErrorLog) _buttonsView(),
          ],
        ),
      ),
    );
  }

  _infoView() {
    return GestureDetector(
      onTap: showInformation,
      child: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: Icon(
          Icons.info,
          color: Colors.grey,
        ),
      ),
    );
  }

  _userProfileView() {
    return const Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: 32,
        width: 32,
        child: CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/user_profile_pic.png'),
        ),
      ),
    );
  }

  void showInformation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
        content: SingleChildScrollView(child: Text(widget.logMessage)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.network(
          imageUrl,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  List<DataColumn> generateColumns(List<dynamic> row) {
    return List.generate(
      row.length,
      (index) => DataColumn(
        label: SizedBox(
          // Distribute width evenly for each column
          child: Text(row[index].toString()),
        ),
      ),
    );
  }

  _tableView() {
    print("222222 tableView");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Tabular Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              // columnSpacing: 12,
              dataRowHeight: 40,
              columns: generateColumns(widget.tableColumnData!),
              rows: List.generate(
                widget.tableRowData!.length,
                (index) => DataRow(
                  cells: List.generate(
                    widget.tableRowData![index]!.length,
                    (cellIndex) => DataCell(
                      SizedBox(
                        child: Text(
                            widget.tableRowData![index][cellIndex].toString()),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _imageView() {
    print("222222 imageView");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            showImage(widget.imageUrl!);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Image.network(
              widget.imageUrl!,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  _textView() {
    return SelectableText(
      widget.text,
      style: TextStyle(
        color: widget.isUser ? Colors.white : Colors.black87,
      ),
    );
  }

  _buttonsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () async {
            await pushData("auto");
          },
          child: const Text('Auto Fix'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            _updateSqlQuery();
            // await pushData("manual");
          },
          child: const Text('Manual Fix'),
        ),
      ],
    );
  }

  _updateSqlQuery() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update SQL Query'),
          content: SingleChildScrollView(child: Text(widget.logMessage)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                await pushData("manual");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  pushData(String fix) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    print("wewewew DateTime before push:: $formattedDate");
    await ref.child(timeStamp).set({
      "isUser": true,
      "message": widget.text,
      "image_url": widget.imageUrl,
      "language": AppState.instance.language.toLowerCase(),
      "model_uuid": AppState.instance.modelUUID,
      "mode": AppState.instance.mode,
      "fix_type": fix,
      "error_log": widget.errorLog,
      "assistant_response": widget.logMessage,
      "sql_ts": widget.timestampMapping!['sql_ts'] ?? '',
      "error_ts": widget.timestampMapping!['error_ts'] ?? '',
      "table_ts": widget.timestampMapping!['table_ts'] ?? '',
      "image_ts": widget.timestampMapping!['image_ts'] ?? '',
      "summary_ts": widget.timestampMapping!['summary_ts'] ?? '',
      "user_response": ''
    });
  }
}
