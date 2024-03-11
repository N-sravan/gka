import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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


  @override
  void initState() {
    initSpeech();
    super.initState();
  }

  initSpeech() async{
    _speechEnabled = await _speechToText.initialize();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult, localeId: widget.localeId);
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

  void _onSpeechResult(SpeechRecognitionResult result) {
    widget.updateSpeech(result.recognizedWords);
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
      icon: iconSwitcher(Icons.mic_off, Colors.red, Icons.mic, Colors.green, speechToTextOn),
    );
  }

  AnimatedSwitcher iconSwitcher(IconData icon1, Color icon1Color, IconData icon2, Color icon2Color, bool switchIcon) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: child.key == const ValueKey('icon1')
              ? Tween<double>(begin: 1, end: 1).animate(anim)
              : Tween<double>(begin: 1, end: 1).animate(anim),
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: switchIcon == false
            ? Icon(icon1, key: const ValueKey('icon1'), color: icon1Color)
            : Icon(icon2, key: const ValueKey('icon2'), color: icon2Color)
    );
  }
}
