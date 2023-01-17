import 'dart:developer';

import 'package:chat_gtp_assistent/services/open_ai_service.dart';
import 'package:chat_gtp_assistent/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AddApiKey extends StatefulWidget {
  const AddApiKey({Key? key}) : super(key: key);

  @override
  State<AddApiKey> createState() => _AddApiKeyState();
}

class _AddApiKeyState extends State<AddApiKey> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add API Key',
          style: TextStyle(
            color: Colors.black,
            fontSize: 23,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To use this app you need an API key from OpenAI. Browse the following URL at your launcher',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SelectableText(
                      'https://beta.openai.com/account/api-keys',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 11, 75, 29),
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'There, you must create an account (if you do not have yet) and then create an API key. Copy the key and paste it in the text field below. ',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Paste your API key here',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 40, 33, 243),
                        ),
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          await OpenAiService()
                              .request(
                                  'hello', 'chat', _apiKeyController.text, 200)
                              .then(
                            (value) async {
                              final messenger = ScaffoldMessenger.of(context);
                              if (value.statusCode == 401) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invalid API key, try with another',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else if (value.statusCode == 200) {
                                const storage = FlutterSecureStorage();
                                await storage.write(
                                    key: 'apiKey',
                                    value: _apiKeyController.text);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'API key added successfully',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Home(),
                                  ),
                                );
                              }
                            },
                          ).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error, try again later',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          });
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: const Text(
                          'Submit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
