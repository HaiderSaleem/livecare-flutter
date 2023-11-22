import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormSectionDataModel {
  List<FormFieldDataModel> arrayFields = [];
  String szHeader = "";
  String szLabel = "";
  String szKey = "";

  FormSectionDataModel() {
    initialize();
  }

  initialize() {
    szHeader = "";
    szLabel = "";
    szKey = "";
    arrayFields = [];
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("header")) {
        szHeader = UtilsString.parseString(dictionary["header"]);
      }
      if (dictionary.containsKey("label")) {
        szLabel = UtilsString.parseString(dictionary["label"]);
      }
      if (dictionary.containsKey("key")) {
        szKey = UtilsString.parseString(dictionary["key"]);
      }
      if (dictionary.containsKey("fields") && dictionary["fields"] != null) {
        final List<dynamic> fields = dictionary["fields"];
        for (int i in Iterable.generate(fields.length)) {
          final Map<String, dynamic> dict = fields[i];
          final field = FormFieldDataModel();
          field.deserialize(dict);
          if (field.isValid()) {
            arrayFields.add(field);
          }
        }
      }
    } catch (error) {
      UtilsGeneral.log("response: " + error.toString());
    }
  }

  Map<String, dynamic>? serialize() {
    final Map<String, dynamic> jsonObject = {};
    final List<dynamic> array = [];
    for (var field in arrayFields) {
      array.add(field.serialize());
    }
    try {
      jsonObject["header"] = szHeader;
      jsonObject["label"] = szLabel;
      jsonObject["key"] = szKey;
      jsonObject["fields"] = array;
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    return jsonObject;
  }

  bool isValid() {
    return true; //(arrayFields.length > 0);
  }

  FormFieldDataModel? getFieldByKey(String? fieldKey) {
    for (var field in arrayFields) {
      if (field.szFieldKey == fieldKey) {
        return field;
      }
    }
    return null;
  }
}
