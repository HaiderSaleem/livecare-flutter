import 'package:livecare/utils/utils_string.dart';

class FormFieldDataSourceDataModel {
  String szName = "";
  String szValue = "";

  FormFieldDataSourceDataModel() {
    initialize();
  }

  initialize() {
    szName = "";
    szValue = "";
  }

  deserializeFromString(dynamic value) {
    initialize();
    if (value is String) {
      final String mValue = value;
      szName = mValue;
      szValue = mValue;
    }
  }

  deserializeFromDictionary(Map<String, dynamic> dictionary) {
    initialize();
    szName = UtilsString.parseString(dictionary["name"]);
    szValue = UtilsString.parseString(dictionary["value"]);
  }

  String serializeToString() => szValue;

  Map<String, dynamic> serializeToDictionary() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["name"] = szName;
    jsonObject["value"] = szValue;
    return jsonObject;
  }

  bool isValid() => !(szName.isEmpty && szValue.isEmpty);
}
