import 'dart:io';

class MessageBubble {
  String? message;
  File? image;
  bool user;
  bool textToSpeechEnabled;
  bool isResponseLoading;
  bool isTextToSpeechRunning;
  MessageBubble({this.message, this.image, required this.user, required this.textToSpeechEnabled, required this.isResponseLoading, required this.isTextToSpeechRunning});
}