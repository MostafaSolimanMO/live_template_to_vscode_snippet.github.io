// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  /// map the xml body string to a splitted list by going through the [snippetBodyStringfier]
  List<String> snippetBodyMapper(String value) =>
      value.split('\n').map<String>(snippetBodyStringfier).toList();

  /// trim each line of code passed from [snippetBodyMapper] map function 
  /// and applying the double quotation marks and passing it to [fixSnippetBodyCursor]
  /// to format the cursor indicator to satifiy [vscode] needs
  String snippetBodyStringfier(String str) {
    return '"${str.trim().replaceFirstMapped(RegExp(r"\$.*?\$"), fixSnippetBodyCursor)}"';
  }

  /// by default the [template] cursor is $value$ and this doesn't go well
  /// with [vscode] needs so we have to remove the last $ symbol
  /// so it just be $value so you can use it with no hassel <3  
  String fixSnippetBodyCursor(Match match) {
    var str = match.group(0);
    if (str != null && str.isNotEmpty) {
      str = str.substring(0, str.length - 1);
    }
    return str!;
  }

  void convert() async {
    final Map<String, dynamic> snippet = {};

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      dialogTitle: "Select live template xml file",
      allowedExtensions: ['xml'],
    );

    if (result != null) {
      // Parse/Read xml file
      final fileBytes = utf8.decode(result.files.single.bytes!.cast<int>());
      final xml = XmlDocument.parse(fileBytes);

      // Loop through the xml doc
      for (final template in xml.findAllElements("template").toList()) {
        // convert template to snippet by parsing it into snippet formula
        snippet.addEntries({
          '"${template.attributes[2].value}"': {
            '"prefix"': '"${template.attributes[0].value}"',
            '"body"': snippetBodyMapper(template.attributes[1].value)
          }
        }.entries);
      }

      // download the file by converting the snippet object into bytes and download it
      // using 'a' tag and assigning donwload href attribute
      // and executing onClick using anchorElement.click()
      final rawData = snippet.toString().codeUnits;
      final content = base64Encode(rawData);
      AnchorElement(
          href: "data:application/json;charset=utf-16le;base64,$content")
        ..setAttribute(
            "download",
            // setting downloaded file name to the corrisponding langauge name .json
            // according to the live template file
            "${xml.findAllElements('option').toList().first.getAttribute("name")!.toLowerCase()}.json")
        ..click();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Intellij live template to vscode snippet converter"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: convert,
            child: const Text("Select template file *.xml")),
      ),
    );
  }
}
