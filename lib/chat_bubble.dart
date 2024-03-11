import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);
  final String text;
  final bool isUser;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        widget.isUser ? 64.0 : 16.0,
        4,
        widget.isUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        // align the child within the container
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
            mainAxisAlignment:
                widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isUser
                  ? const SizedBox()
                  : const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('assets/images/vani.png')),
                      ),
                    ),
              Flexible(
                child: DecoratedBox(
                  // chat bubble decoration
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
                              bottomRight: Radius.circular(16))),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: widget.isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
              widget.isUser
                  ? const Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(
                                'assets/images/user_profile_pic.png')),
                      ),
                    )
                  : const SizedBox()
            ]),
      ),
    );
  }
}
