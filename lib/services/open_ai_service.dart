import 'dart:convert';
import 'dart:developer';

import 'package:chat_gtp_assistent/constants/constants.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  Future<http.Response> request(
      String propmt, String mode, String apiKey, int maxTokens) async {
    final String apiUrl =
        mode == 'chat' ? 'v1/completions' : 'v1/images/generations';

    final body = mode == 'chat'
        ? {
            "model": "text-davinci-003",
            "prompt": propmt,
            "max_tokens": 2000,
            "temperature": 0.9,
            "n": 1,
          }
        : {
            "prompt": propmt,
          };

    final response = await http.post(
      Uri.parse('$openaiApiUrl$apiUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode(body),
    );
    return response;
  }
}
