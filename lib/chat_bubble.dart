import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
    this.imageUrl,
  }) : super(key: key);
  String text;
  final bool isUser;
  final String? imageUrl;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.isUser ? 64.0 : 16.0,
        4,
        widget.isUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isUser)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/vani.png'),
                  ),
                ),
              ),
           widget.imageUrl != null && widget.imageUrl!.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                    child: Image.network(
                      widget.imageUrl ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ): SizedBox(),
            Flexible(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: !widget.isUser ? Colors.white : Colors.green[400],
                  borderRadius: widget.isUser
                      ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16))
                      : const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.text,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: widget.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isUser)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/user_profile_pic.png'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

