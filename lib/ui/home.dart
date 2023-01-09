import 'dart:convert';
import 'dart:developer' as developer;

import 'package:chat_gtp_assistent/services/open_ai_service.dart';
import 'package:chat_gtp_assistent/widgets/invalid_key_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _sendRequest(String propmt) async {
    _stopListening();
    setState(() {
      _isLoading = true;
    });
    const storage = FlutterSecureStorage();

    final apiKey = await storage.read(key: 'apiKey');
    if (apiKey == null) {
      showDialog(
        context: context,
        builder: (context) => const InvalidKeyDialog(),
      );
      return;
    }
    await OpenAiService().request(propmt, _mode, apiKey, 2000).then(
      (value) {
        setState(() {
          _isLoading = false;
        });
        if (value.statusCode == 401) {
          showDialog(
            context: context,
            builder: (context) => const InvalidKeyDialog(),
          );
          return;
        }
        _textController.clear();
        final res = jsonDecode(value.body);
        if (_mode == 'chat') {
          setState(() {
            response =
                utf8.decode(res['choices'][0]['text'].toString().codeUnits);
          });
          if (_enableAudio) {
            _textToSpeech.speak(response);
          }
        } else {
          setState(() {
            _imgUrl = res['data'][0]['url'];
          });
        }
      },
    ).catchError(
      (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong'),
          ),
        );
      },
    );
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    FocusScope.of(context).unfocus();
    await _speechToText.listen(onResult: _onSpeechResult);

    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _audioRecorded = (result.recognizedWords);

    _speechToText.isListening ? null : _sendRequest(_audioRecorded);
  }

  final SpeechToText _speechToText = SpeechToText();
  final TextToSpeech _textToSpeech = TextToSpeech();
  final _textController = TextEditingController();
  String _audioRecorded = '';
  String response = '';
  bool _isLoading = false;
  bool _enableAudio = true;
  String _mode = 'chat';
  String _imgUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Center(
                child: InkWell(
                  onTap: () {
                    _speechToText.isListening
                        ? _stopListening()
                        : _startListening();
                  },
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: _speechToText.isListening
                          ? const Color.fromARGB(255, 54, 184, 244)
                          : _isLoading
                              ? const Color.fromARGB(255, 183, 191, 195)
                              : const Color.fromARGB(255, 40, 33, 243),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () {
                  if (!_isLoading) {
                    setState(() {
                      _enableAudio = !_enableAudio;
                    });
                    _textToSpeech.stop();
                  }
                },
                child: Icon(
                  _enableAudio ? Icons.mic_outlined : Icons.mic_off,
                  size: 40,
                  color: _isLoading
                      ? const Color.fromARGB(255, 183, 191, 195)
                      : _enableAudio
                          ? const Color.fromARGB(255, 33, 40, 243)
                          : Colors.red,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      _mode = 'chat';
                    }),
                    child: Icon(
                      Icons.chat_outlined,
                      size: 40,
                      color: _mode == 'chat'
                          ? Colors.black
                          : const Color.fromARGB(255, 183, 191, 195),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => setState(() {
                      _mode = 'image';
                    }),
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: _mode == 'image'
                          ? Colors.black
                          : const Color.fromARGB(255, 183, 191, 195),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: !_speechToText.isListening && !_isLoading,
                      controller: _textController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What can i do tonight',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      _textController.text.isNotEmpty
                          ? _sendRequest(_textController.text)
                          : null;
                    },
                    child: AnimatedContainer(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _speechToText.isNotListening && !_isLoading
                            ? const Color.fromARGB(255, 33, 40, 243)
                            : _isLoading
                                ? const Color.fromARGB(255, 183, 191, 195)
                                : const Color.fromARGB(255, 108, 112, 221),
                      ),
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _mode == 'chat'
                  ? SelectableText(
                      response,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    )
                  : _mode == 'image' && _imgUrl.isNotEmpty
                      ? Image.network(_imgUrl)
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
