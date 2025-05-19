import 'package:flutter/material.dart';


class ChatBubble extends StatefulWidget {
  final String timestamp;
  final String text;
  final bool isUser;
  final String imageUrl;
  final List<dynamic>? tableColumnData;
  final List<dynamic>? tableRowData;
  final String logMessage;
  final bool hasErrorLog;
  final Map<String, String> timestampMapping;
  final List<String> followUpQuestions;
  final String token;
  final bool isMapView;

  final bool expandContentBlocks;
  final bool isStreaming;
  final Map<String, dynamic>? contentBlocks;

  const ChatBubble({
    Key? key,
    required this.timestamp,
    required this.text,
    required this.isUser,
    required this.imageUrl,
    this.tableColumnData,
    this.tableRowData,
    required this.logMessage,
    required this.hasErrorLog,
    required this.timestampMapping,
    required this.followUpQuestions,
    required this.token,
    required this.isMapView,
    required this.expandContentBlocks,
    this.isStreaming = false,
    this.contentBlocks,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  ValueNotifier<bool> show = ValueNotifier<bool>(true);
  Map<String, bool> _expanded = {};
  List<Color> colors = [
    const Color(0xFFCFE2FF).withOpacity(0.5), //blue
    const Color(0xFFFFF3CD).withOpacity(0.5), //yellow
    const Color(0xFFf8d7da).withOpacity(0.5), //pink
    const Color(0xFFcff4fc).withOpacity(0.5), //skyblue
  ];

  @override
  void initState() {
    super.initState();
    show.value = widget.expandContentBlocks!;
    _expanded = {};
    if (widget.contentBlocks != null) {
      for (String key in widget.contentBlocks!.keys) {
        _expanded[key] = false;
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.fromLTRB(
            widget.isUser ? 64.0 : 16.0, 4, widget.isUser ? 16.0 : 8.0, 4),
        child: Align(
            alignment:
                widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(children: [
              if (widget.isUser &&
                  widget.contentBlocks != null &&
                  widget.contentBlocks!.isNotEmpty)
                ValueListenableBuilder(
                  builder: (context, value, _) {
                    return (show.value &&
                            widget.contentBlocks != null &&
                            widget.contentBlocks!.isNotEmpty)
                        ? showContentBlocks()
                        : const SizedBox();
                  },
                  valueListenable: show,
                ),
              Row(
                  mainAxisAlignment: widget.isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.isUser)
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/male_bot.jfif'),
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.isUser
                              ? const Color(0xffE2E3E4).withOpacity(0.6)
                              : const Color(0xFFcff4fc).withOpacity(0.5),
                          // : Colors.green[500],
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
                          // padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.text.isNotEmpty) _formattedTextView(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.isUser) _userProfileView(),
                  ]),
            ])));
  }

  _formattedTextView() {
    // Trim the text and handle single quotes
    String trimmedText = widget.text.trim().replaceAll("'", "");
    if (trimmedText.startsWith("'")) {
      trimmedText = trimmedText.substring(1);
    }
    if (trimmedText.endsWith("'")) {
      trimmedText = trimmedText.substring(0, trimmedText.length - 1);
    }
    if (trimmedText.endsWith('"')) {
      trimmedText = trimmedText.substring(0, trimmedText.length - 1);
    }

    trimmedText.replaceAll('\u200c', '');
    // Split the text by line breaks (\\n)
    List<String> lines = trimmedText.split('\\n');

    // Process each line to apply bold formatting and replace '*' with '•'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Apply bold formatting first
        final boldTextLine = _parseText(line);

        // Replace '*' with '•' in the bold formatted text
        final bulletPointText = boldTextLine.map((span) {
          String text = span.text ?? '';
          return TextSpan(
            text: text.replaceAll('*', ''),
            style: span.style,
          );
        }).toList();

        return RichText(
          text: TextSpan(
            children: bulletPointText,
            style: const TextStyle(
              color: Color(0xff1E1E1E),
              fontSize: 14.0, // adjust as needed
            ),
          ),
        );
      }).toList(),
    );
  }

  List<TextSpan> _parseText(String text) {
    text.replaceAll('\u200c', '');
    // Split text by new lines
    final lines = text.split('\n');

    return lines.map((line) {
      if (line.trim().startsWith('*')) {
        // If line starts with '*', make it bold
        return TextSpan(
          text: '${line.trim()}\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      } else {
        // Regular text
        return TextSpan(
          text: '${line.trim()}\n',
          style: const TextStyle(fontWeight: FontWeight.normal),
        );
      }
    }).toList();
  }

  _userProfileView() {
    return SizedBox(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: SizedBox(
              height: 32,
              width: 32,
              child: CircleAvatar(
                radius: 0,
                backgroundImage: AssetImage('assets/images/vani.png'),
              ),
            ),
          ),
          (widget.contentBlocks != null && widget.contentBlocks!.isNotEmpty)
              ? ValueListenableBuilder(
                  builder: (context, value, _) {
                    return IconButton(
                      onPressed: () {
                        show.value = !show.value;
                      },
                      icon: show.value
                          ? const Icon(Icons.keyboard_arrow_up)
                          : const Icon(Icons.keyboard_arrow_down),
                    );
                  },
                  valueListenable: show,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget showContentBlocks() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.black.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agent Steps',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...widget.contentBlocks!.entries.map((entry) {
                    int colorIndex = widget.contentBlocks!.keys
                        .toList()
                        .indexOf(entry.key) %
                        4;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _expanded[entry.key] = !(_expanded[entry.key] ?? false);
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: colors[colorIndex],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key.trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (_expanded[entry.key] == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
