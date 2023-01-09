import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/add_api_key.dart';

class InvalidKeyDialog extends StatelessWidget {
  const InvalidKeyDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Invalid API key',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
              'Maybe the ApiKey you were using expired or it is not available anymore. Whatever, you can find one new at:'),
          SelectableText(
            'https://beta.openai.com/account/api-keys',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color.fromARGB(255, 11, 75, 29),
              fontSize: 18,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddApiKey(),
              ),
            );
          },
          child: const Text(
            'Add new API key',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Ok',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
