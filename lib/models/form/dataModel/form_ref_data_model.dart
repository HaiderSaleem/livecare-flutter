import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class FormRefDataModel {
  String formId = "";
  String submissionId = "";
  String szName = "";

  initialize() {
    formId = "";
    szName = "";
    submissionId = "";
  }

  deserialize(Map<String, dynamic> dictionary) {
    initialize();
    formId = UtilsString.parseString(dictionary["formId"]);
    if (UtilsBaseFunction.containsKey(dictionary, "submissionId")) {
      submissionId = UtilsString.parseString(dictionary["submissionId"]);
    }
    szName = UtilsString.parseString(dictionary["name"]);
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["formId"] = formId;
    jsonObject["name"] = szName;
    jsonObject["name"] = submissionId;
    return jsonObject;
  }

  bool isValid() => formId.isNotEmpty;
}
