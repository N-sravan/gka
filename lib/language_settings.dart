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
      backgroundColor: const Color(0xFFFCF6FC),
      appBar: AppBar(
        title: const Text("Language Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          _buildSection("Choose Language", langList, selectedLanguage,
                  (value) => setState(() => selectedLanguage = value)),
          _buildSection("Speech Recognition Services", speechServicesList,
              selectedSpeechService, (value) => setState(() => selectedSpeechService = value)),
          _buildSection("TTS Services", ttsServicesList, selectedTTSService,
                  (value) => setState(() => selectedTTSService = value)),
          _buildSection("Translation Services", translationServicesList,
              selectedTranslationService, (value) => setState(() => selectedTranslationService = value)),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                _updateAppStateValues();
                Fluttertoast.showToast(msg: 'Settings Saved!');
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                backgroundColor: const Color(0xF0F1E9FA),
                foregroundColor: const Color(0xFF623E98),
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

  Widget _buildSection(
      String title,
      List<String> options,
      String selected,
      Function(String) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 10),
          ...options.map((option) => Theme(
            data: Theme.of(context).copyWith(
              unselectedWidgetColor: Colors.grey,
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return const Color(0xFF623E98); // Purple color
                  },
                ),
              ),
            ),
            child: RadioListTile<String>(
              title: Text(option),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              value: option,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
              visualDensity: const VisualDensity(vertical: -2),
            ),
          )),
        ],
      ),
    );
  }

  void _updateAppStateValues() {
    AppState.instance.language = selectedLanguage;
    AppState.instance.isEnglish = selectedLanguage.toLowerCase() == 'english';
    AppState.instance.sttMode = selectedSpeechService;
    AppState.instance.ttsMode = selectedTTSService;
    AppState.instance.transMode = selectedTranslationService;

    print(
        "AppState langSelected ${AppState.instance.language}\n STT : ${AppState.instance.sttMode}\n TTS : ${AppState.instance.ttsMode}\n Translation: ${AppState.instance.transMode}");
  }
}
