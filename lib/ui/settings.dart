import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void didChangeDependencies() async {
    prefs = await SharedPreferences.getInstance();
    final currentCode = prefs.getString('language');

    if (currentCode != null) {
      setState(() {
        _selectedLanguage = _languages.firstWhere(
          (element) => _languageCode[element] == currentCode,
        );
      });
    }
    super.didChangeDependencies();
  }

  String? _selectedLanguage;
  final List<String> _languages = [
    'English (US)',
    'English (UK)',
    'Español (US)',
    'Español (Es)',
    'Français (France)',
    'Português (Brasil)',
    'Português (Portugal)',
    'Deutsch (Deutschland)',
    'Italiano (Italia)',
  ];

  final Map<String, String> _languageCode = {
    'English (US)': 'en-US',
    'English (UK)': 'en-GB',
    'Español (US)': 'es-US',
    'Español (Es)': 'es-ES',
    'Français (France)': 'fr-FR',
    'Português (Brasil)': 'pt-BR',
    'Português (Portugal)': 'pt-PT',
    'Deutsch (Deutschland)': 'de-DE',
    'Italiano (Italia)': 'it-IT',
  };
  late SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change the voice language',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select language'),
              value: _selectedLanguage,
              onChanged: (String? newValue) async {
                final code = _languageCode[newValue];
                prefs.setString('language', code!);
                setState(() {
                  _selectedLanguage = newValue;
                });
              },
              items: _languages.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
