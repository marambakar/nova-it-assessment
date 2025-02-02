import 'package:flutter/material.dart';
import 'dart:io';

class ResultScreen extends StatelessWidget {
  final String imagePath;

  const ResultScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captured Image")),
      body: Column(
        children: [
          Image.file(File(imagePath)),
          Text("Captured on: ${DateTime.now()}"),
        ],
      ),
    );
  }
}
