import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';

import 'chat/view_model/chat_view_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'English';
  String selectedAppLanguage = 'English';
  String selectedSpeechService = 'Native';
  String selectedTTSService = 'Native';
  String selectedTranslationService = 'Bhashini';
  bool showChainOfActions = true;
  bool showDetailedMode = true;
  bool autoSpeechEnabled = false;

  final langList = ['English', 'Telugu'];
  final speechServicesList = ['Native', 'Bhashini','Parakeet'];
  final ttsServicesList = ['Native', 'Bhashini', 'Resemble AI'];
  final translationServicesList = ['Google Translate', 'Bhashini' , 'LLM Translate'];
  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    selectedLanguage = AppState.instance.language;
    selectedSpeechService = AppState.instance.sttMode;
    selectedTTSService = AppState.instance.ttsMode;
    selectedTranslationService = AppState.instance.transMode;
    showChainOfActions = AppState.instance.showChainOfActions;
    showDetailedMode = AppState.instance.showDetailedMode;
    autoSpeechEnabled = AppState.instance.autoSpeechEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(builder: (_, viewModel, child) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("Language"),
            const SizedBox(height: 8),
            _buildSettingItem(
              "App Language",
              selectedAppLanguage,
              () => _showLanguageSelector(
                  "App Language", ['English'], selectedLanguage, (value) {
                setState(() => selectedAppLanguage = value);
              }),
            ),
            _buildSettingItem(
              "Chat Language",
              selectedLanguage,
              () => _showLanguageSelector(
                  "Input Language", langList, selectedLanguage, (value) {
                setState(() => selectedLanguage = value);
              }),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Translator Engine"),
            const SizedBox(height: 8),
            _buildSettingItem(
              "Translator Engine",
              selectedTranslationService,
              () => _showServiceSelector("Translator Engine",
                  translationServicesList, selectedTranslationService, (value) {
                setState(() => selectedTranslationService = value);
              }),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Speech Synthesizer"),
            const SizedBox(height: 8),
            _buildSettingItem(
              "Speech Synthesizer",
              selectedTTSService,
              () => _showServiceSelector(
                  "Speech Synthesizer", ttsServicesList, selectedTTSService,
                  (value) {
                setState(() => selectedTTSService = value);
              }),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Speech Recognition Engine"),
            const SizedBox(height: 8),
            _buildSettingItem(
              "Speech Recognition Engine",
              selectedSpeechService,
              () => _showServiceSelector("Speech Recognition Engine",
                  speechServicesList, selectedSpeechService, (value) {
                setState(() => selectedSpeechService = value);
              }),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Chat Display Options"),
            const SizedBox(height: 8),
            _buildToggleItem(
              "Show Chain of Actions",
              "Display processing steps during AI responses",
              showChainOfActions,
              (value) {
                setState(() {
                  showChainOfActions = value;
                  AppState.instance.showChainOfActions = value;
                });
                Fluttertoast.showToast(msg: 'Chain of Actions ${value ? 'Enabled' : 'Disabled'}!');
              },
            ),
            _buildToggleItem(
              "Show Detailed Information",
              "Include technical details in processing steps",
              showDetailedMode,
              (value) {
                setState(() {
                  showDetailedMode = value;
                  AppState.instance.showDetailedMode = value;
                });
                Fluttertoast.showToast(msg: 'Detailed Mode ${value ? 'Enabled' : 'Disabled'}!');
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Auto Speech"),
            const SizedBox(height: 8),
            _buildToggleItem(
              "Auto Speech",
              "Automatically speak AI responses using chunk-wise TTS",
              autoSpeechEnabled,
              (value) {
                setState(() {
                  autoSpeechEnabled = value;
                  AppState.instance.autoSpeechEnabled = value;
                });
                Fluttertoast.showToast(msg: 'Auto Speech ${value ? 'Enabled' : 'Disabled'}!');
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSettingItem(
      String title, String selectedValue, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedValue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(
      String title, String description, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4CAF50),
                  activeTrackColor: const Color(0xFF4CAF50).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(String title, List<String> options,
      String currentValue, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ...options.map((option) => ListTile(
                    title: Text(option),
                    trailing: currentValue == option
                        ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                        : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                      _updateAppStateValues();
                      Fluttertoast.showToast(msg: 'Settings Updated!');
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showServiceSelector(String title, List<String> options,
      String currentValue, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ...options.map((option) => ListTile(
                    title: Text(option),
                    trailing: currentValue == option
                        ? const Icon(Icons.check, color: Color(0xFF4CAF50))
                        : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                      _updateAppStateValues();
                      Fluttertoast.showToast(msg: 'Settings Updated!');
                    },
                  )),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _updateAppStateValues() {
    AppState.instance.language = selectedLanguage;
    AppState.instance.isEnglish =
        selectedLanguage.toLowerCase() == 'english' ? true : false;
    AppState.instance.sttMode = selectedSpeechService;
    AppState.instance.ttsMode = selectedTTSService;
    AppState.instance.transMode = selectedTranslationService;

    viewModel.setlangCodes();

    print("Langcodes LangId - ${viewModel.langId}\n isEnglish ${AppState.instance.isEnglish}\n");
    print("Langcodes currentVoice - ${viewModel.currentVoice}");
    print("AppState langSelected ${AppState.instance.language}\n STT : ${AppState.instance.sttMode}\n TTS : ${AppState.instance.ttsMode}\n Translation: ${AppState.instance.transMode}");
  }
}
