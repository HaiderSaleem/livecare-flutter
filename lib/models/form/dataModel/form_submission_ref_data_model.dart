import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormSubmissionRefDataModel {
  String submissionId = "";
  String formId = "";
  String szFormName = "";

  FormSubmissionRefDataModel() {
    initialize();
  }

  initialize() {
    submissionId = "";
    formId = "";
    szFormName = "";
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("submissionId")) {
        submissionId = UtilsString.parseString(dictionary["submissionId"]);
      }
      if (dictionary.containsKey("formId")) {
        formId = UtilsString.parseString(dictionary["formId"]);
      }
      if (dictionary.containsKey("formName")) {
        szFormName = UtilsString.parseString(dictionary["formName"]);
      }
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
  }

  Map<String, dynamic>? serialize() {
    final Map<String, dynamic> json = {};
    try {
      json["submissionId"] = submissionId;
      json["formId"] = formId;
      json["formName"] = szFormName;
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    return json;
  }

  bool isValid() {
    return submissionId.isNotEmpty;
  }
}
