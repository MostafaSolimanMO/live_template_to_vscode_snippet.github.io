import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'converter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void convert() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      dialogTitle: "Select live template xml file",
      allowedExtensions: ['xml'],
    );

    if (result != null) {
      XmlFileConverter(result.files.single)
        ..convert()
        ..download();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 240, 236, 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Made by a need",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 42,
                ),
                const Text(
                  'Intellij Live Template to VScode Snippet Converter',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  'Convert your favorite Live Templates to Snippet easy and fast.',
                  style: TextStyle(
                    fontSize: 26,
                  ),
                ),
                const SizedBox(
                  height: 56,
                ),
                ElevatedButton(
                  onPressed: convert,
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 235, 53, 40),
                    onPrimary: Colors.black,
                    onSurface: Colors.black,
                    minimumSize: const Size(72, 64),
                    padding: const EdgeInsets.all(32),
                  ),
                  child: const Text(
                    "Select template file *.xml",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
