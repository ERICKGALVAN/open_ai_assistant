import 'dart:developer';

import 'package:chat_gtp_assistent/ui/add_api_key.dart';
import 'package:chat_gtp_assistent/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  String? value = await storage.read(key: 'apiKey');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: value == null ? const AddApiKey() : const Home(),
    ),
  );
}
