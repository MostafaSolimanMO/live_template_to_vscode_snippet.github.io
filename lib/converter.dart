import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class XmlFileConverter {
  final PlatformFile file;

  late Map<String, dynamic> snippet;
  late XmlDocument xml;

  XmlFileConverter(this.file) {
    snippet = {};

    /// Our snippet file
    xml = XmlDocument.parse(utf8.decode(file.bytes!.cast<int>()));
  }

  convert() {
    /// Loop through the xml doc
    for (final template in xml.findAllElements("template").toList()) {
      /// convert template to snippet by parsing it into snippet formula
      /// Ervery Live Template Xml file looks like this:
      ///
      /// <templateSet group="Cubit">
      /// <template name="cub"
      ///           value="import 'package:bloc/bloc.dart'; Etc.."
      ///           description="Implemet of cubit class"
      ///           toReformat="false"
      ///           toShortenFQNames="true">
      ///   <variable name="NAME"
      ///             expression=""
      ///             defaultValue=""
      ///              alwaysStopAt="true"/>
      ///   <context>
      ///     <option
      ///         name="DART"
      ///         value="true"/>
      ///   </context>
      /// </template>
      /// </templateSet>
      ///
      /// Sinnpet Title => template : description : 0
      /// Sinnpet prefix => template : name : 2
      /// Sinnpet body => template : value : 1
      ///
      snippet.addEntries({
        '"${template.attributes[2].value}"': {
          '"prefix"': '"${template.attributes[0].value}"',
          '"body"': _snippetBodyMapper(template.attributes[1].value)
        }
      }.entries);
    }
  }

  List<String> _snippetBodyMapper(String value) =>
      value.split('\n').map<String>(_snippetBodyStringfier).toList();

  /// Trim each line of code passed from [snippetBodyMapper] map function
  /// and applying the double quotation marks and passing it to [fixSnippetBodyCursor]
  /// to format the cursor indicator to satifiy [vscode] needs
  String _snippetBodyStringfier(String str) =>
      '"${str.trim().replaceFirstMapped(RegExp(r"\$.*?\$"), _fixSnippetBodyCursor)}"';

  /// By default the [template] cursor is $value$ and this doesn't go well
  /// with [vscode] needs so we have to remove the last $ symbol
  /// so it just be $value so you can use it with no hassel <3
  String _fixSnippetBodyCursor(Match match) {
    var str = match.group(0);
    if (str != null && str.isNotEmpty) {
      str = str.substring(0, str.length - 1);
    }
    return str!;
  }

  download() {
    /// Using 'a' tag and assigning donwload href attribute
    /// and executing onClick using anchorElement.click()
    final rawData = snippet.toString().codeUnits;
    final content = base64Encode(rawData);
    AnchorElement(
        href: "data:application/json;charset=utf-16le;base64,$content")
      ..setAttribute(
          "Download",

          /// setting downloaded file name to the corrisponding langauge name .json
          /// according to the live template file
          "${xml.findAllElements('option').toList().first.getAttribute("name")!.toLowerCase()}.json")
      ..click();
  }
}
