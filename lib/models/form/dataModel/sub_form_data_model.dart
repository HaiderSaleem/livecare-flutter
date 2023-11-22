import 'package:livecare/models/form/dataModel/form_field_data_model.dart';
import 'package:livecare/models/form/dataModel/form_section_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class SubFormDataModel {
  String szFormName = "";
  List<FormSectionDataModel> arraySections = [];
  String szTitleFieldKey = "";
  bool allowMultipleInstances = false;
  Map<String, dynamic> dictCopy = {};

  SubFormDataModel() {
    initialize();
  }

  initialize() {
    szFormName = "";
    arraySections = [];
    szTitleFieldKey = "";
    allowMultipleInstances = false;
    dictCopy = {};
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("name")) {
        szFormName = UtilsString.parseString(dictionary["name"]);
      }
      if (dictionary.containsKey("sections") &&
          dictionary["sections"] != null) {
        final List<dynamic> sections = dictionary["sections"];
        for (int i in Iterable.generate(sections.length)) {
          final dict = sections[i];
          final section = FormSectionDataModel();
          section.deserialize(dict);
          if (section.isValid()) {
            arraySections.add(section);
          }
        }
      }
    } catch (error) {
      UtilsGeneral.log("response: " + error.toString());
    }
    dictCopy = dictionary;
  }

  Map<String, dynamic>? serialize() {
    final List<dynamic> array = [];
    for (var section in arraySections) {
      array.add(section.serialize());
    }
    final Map<String, dynamic> dic = {};
    try {
      dic["name"] = szFormName;
      dic["sections"] = array;
    } catch (error) {
      UtilsGeneral.log("response: " + error.toString());
    }
    return dic;
  }

  bool isValid() {
    return arraySections.isNotEmpty;
  }

  SubFormDataModel? cloneModel() {
    final SubFormDataModel newModel = SubFormDataModel();
    newModel.deserialize(dictCopy);
    newModel.szTitleFieldKey = szTitleFieldKey;
    newModel.allowMultipleInstances = allowMultipleInstances;
    return newModel;
  }

  String getFormTitle() {
    // If titleField is available, we return the value of that field
    final FormFieldDataModel? titleField = getFieldByKey(szTitleFieldKey);
    if (titleField != null &&
        titleField.parsedObject is String &&
        (titleField.parsedObject as String).isNotEmpty) {
      return titleField.parsedObject as String;
    }

    // if allowMultipleInstance allowed, return "New Form"
    return (allowMultipleInstances) ? "New Form *" : szFormName;
  }

  FormFieldDataModel? getFieldByKey(String fieldKey) {
    if (fieldKey.isEmpty) return null;
    for (var section in arraySections) {
      if (section.getFieldByKey(fieldKey) != null) {
        return section.getFieldByKey(fieldKey);
      }
    }
    return null;
  }

  setFormTitle(String title) {
    final FormFieldDataModel? titleField = getFieldByKey(szTitleFieldKey);
    if (titleField != null) {
      titleField.parsedObject = title;
    }
  }
}
