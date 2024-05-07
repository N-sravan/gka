import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    required this.logMessage,
    this.imageUrl,
    this.tabularData, // Add tabularData
  }) : super(key: key);

  final String text;
  final bool isUser;
  final String? imageUrl;
  final List<dynamic>? tabularData; // Define tabularData
  final String logMessage;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  void initState() {
    super.initState();
    print('Image URL :: ${widget.imageUrl}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            if (!widget.isUser)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/vani.png')),
                ),
              ),
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.imageUrl != null &&
                          widget.imageUrl!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Show image from imageUrl
                                showImage(widget.imageUrl!);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Image.network(
                                  widget.imageUrl!,
                                  // width: MediaQuery.of(context).size.width * 0.8,
                                  // height: MediaQuery.of(context).size.height * 0.8,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (widget.tabularData != null &&
                          widget.tabularData!.isNotEmpty)
                        Column(
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
                                  columnSpacing: 12,
                                  dataRowHeight: 40,
                                  columns:
                                      generateColumns(widget.tabularData![0]),
                                  rows: List.generate(
                                    widget.tabularData!.length - 1,
                                    (index) => DataRow(
                                      cells: List.generate(
                                        widget.tabularData![index + 1].length,
                                        (cellIndex) => DataCell(
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: Text(widget
                                                .tabularData![index + 1]
                                                    [cellIndex]
                                                .toString()),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            !widget.isUser
                ? GestureDetector(
                    onTap: showInformation,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.info,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const SizedBox(),
            if (widget.isUser) // Display Vani picture for user
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage('assets/images/user_profile_pic.png'),
                  ),
                ),
              ),
          ],
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
          width: MediaQuery.of(context).size.width * (index + 1) / row.length,
          // Distribute width evenly for each column
          child: Text(row[index].toString()),
        ),
      ),
    );
  }
}
