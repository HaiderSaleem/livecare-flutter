import 'dart:core';
import 'package:livecare/models/form/dataModel/form_page_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormConfigurationDataModel {
  String szFormName = "";
  List<FormPageDataModel> arrayPages = [];
  List<String> arrayReportTemplates = [];
  Map<String, dynamic> payload = {};

  initialize() {
    szFormName = "";
    arrayReportTemplates = [];
    arrayPages = [];
    payload = {};
  }

  deserialize(Map<String, dynamic> dictionary) {
    initialize();
    payload = dictionary;
    szFormName = UtilsString.parseString(dictionary["name"]);

    var reportTemplates = dictionary["reportTemplates"];

    if (reportTemplates is List<String>) {
      arrayReportTemplates = reportTemplates;
    }

    final List<dynamic> pages = dictionary["pages"];
    for (int i in Iterable.generate(pages.length)) {
      var page = FormPageDataModel();
      page.deserialize(pages[i]);
      if (page.isValid()) {
        arrayPages.add(page);
      }
    }
  }

  Map<String, dynamic> serialize() {
    List<dynamic> array = [];
    for (var page in arrayPages) {
      array.add(page.serialize());
    }

    List<dynamic> arrayReportTemplates = [];
    for (var template in arrayReportTemplates) {
      arrayReportTemplates.add(template);
    }
    final Map<String, dynamic> jsonObject = {};
    try {
      jsonObject["name"] = szFormName;
      jsonObject["reportTemplates"] = arrayReportTemplates;
      jsonObject["pages"] = array;
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    return jsonObject;
  }

  bool isValid() => arrayPages.isNotEmpty;
}
