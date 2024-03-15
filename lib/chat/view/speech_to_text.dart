
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:async/async.dart';
import '../../utils/util.dart';

class SpeechToTextWidget extends StatefulWidget {
  const SpeechToTextWidget({
    required this.updateSpeech,
    required this.localeId,
    Key? key
  }) : super(key: key);

  final Function updateSpeech;
  final String localeId;

  @override
  State<SpeechToTextWidget> createState() => _SpeechToTextWidgetState();
}

class _SpeechToTextWidgetState extends State<SpeechToTextWidget> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool speechToTextOn = false;
  String _lastWords = '';
  final memoizer = AsyncMemoizer<void>();


  @override
  void initState() {
    initSpeech();
    super.initState();
  }

  initSpeech() async{
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, localeId: widget.localeId, listenMode: ListenMode.dictation);
    setState(() {
      speechToTextOn = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      speechToTextOn = false;
    });
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    await widget.updateSpeech(result.recognizedWords);
    if (_speechToText.isNotListening) {
      setState(() {
        speechToTextOn = false;
      });
    }
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (speechToTextOn) {
          _stopListening();
        } else {
          _startListening();
        }
      },
      icon: Util.instance.iconSwitcher(Icons.mic_off, Colors.red, Icons.mic, Colors.green, speechToTextOn),
    );
  }
}
