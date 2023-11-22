import 'dart:core';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormPageDataModel {
  List<FormSectionDataModel> arraySections = [];
  String szKey = "";
  String szName = "";

  FormPageDataModel() {
    initialize();
  }

  initialize() {
    arraySections = [];
    szKey = "";
    szName = "";
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    try {
      if (dictionary.containsKey("key")) {
        szKey = UtilsString.parseString(dictionary["key"]);
      }
      if (dictionary.containsKey("name")) {
        szName = UtilsString.parseString(dictionary["name"]);
      }
      if (dictionary.containsKey("sections") &&
          dictionary["sections"] != null) {
        final List<dynamic> sections = dictionary["sections"];
        for (int i in Iterable.generate(sections.length)) {
          var dict = sections[i];
          var section = FormSectionDataModel();
          section.deserialize(dict);
          if (section.isValid()) arraySections.add(section);
        }
      }
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
  }

  Map<String, dynamic>? serialize() {
    final Map<String, dynamic> jsonObject = {};
    final array = [];
    for (var section in arraySections) {
      array.add(section.serialize());
    }
    try {
      jsonObject["key"] = szKey;
      jsonObject["name"] = szName;
      jsonObject["sections"] = array;
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    return jsonObject;
  }

  bool isValid() => arraySections.isNotEmpty;
}
