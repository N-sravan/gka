import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/app_state.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String selectedLanguage = 'English';
  String selectedSpeechService = 'Native';
  String selectedTTSService = 'Native';
  String selectedTranslationService = 'Google Translate';

  final langList = ['English', 'Telugu'];
  final speechServicesList = ['Native', 'Bhashini', 'Parakeet'];
  final ttsServicesList = ['Native', 'Bhashini'];
  final translationServicesList = ['Google Translate', 'Bhashini'];

  @override
  void initState() {
    super.initState();
    selectedLanguage = AppState.instance.language;
    selectedSpeechService = AppState.instance.sttMode;
    selectedTTSService = AppState.instance.ttsMode;
    selectedTranslationService = AppState.instance.transMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language Settings")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSection("Choose Language", langList, selectedLanguage, (value) {
            setState(() => selectedLanguage = value);
          }),
          _buildSection("Speech Recognition Services", speechServicesList,
              selectedSpeechService, (value) {
            setState(() => selectedSpeechService = value);
          }),
          _buildSection("TTS Services", ttsServicesList, selectedTTSService,
              (value) {
            setState(() => selectedTTSService = value);
          }),
          _buildSection("Translation Services", translationServicesList,
              selectedTranslationService, (value) {
            setState(() => selectedTranslationService = value);
          }),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _updateAppStateValues();
                Fluttertoast.showToast(msg: 'Settings Saved!');
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text("Save Settings"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String selected,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          ...options.map((option) => RadioListTile<String>(
                title: Text(option),
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(vertical: -4),
                value: option,
                groupValue: selected,
                onChanged: (value) async {
                  if (value != null) onChanged(value);
                },
              )),
        ],
      ),
    );
  }

  _updateAppStateValues() {
    if (selectedLanguage.toLowerCase() == 'telugu') {
      AppState.instance.language = 'Telugu';
      AppState.instance.isEnglish = false;
    }
    if (selectedLanguage.toLowerCase() == 'english') {
      AppState.instance.language = 'English';
      AppState.instance.isEnglish = true;
    }
    if (selectedSpeechService.isNotEmpty) {
      AppState.instance.sttMode = selectedSpeechService;
    }
    if (selectedTTSService.isNotEmpty) {
      AppState.instance.ttsMode = selectedTTSService;
    }
    if (selectedTranslationService.isNotEmpty) {
      AppState.instance.transMode = selectedTranslationService;
    }

    print(
        "AppState langSelected ${AppState.instance.language}\n STT : ${AppState.instance.sttMode}\n TTS : ${AppState.instance.ttsMode}\n Translation: ${AppState.instance.transMode}");
  }
}
