import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_data_source_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_data_model.dart';
import 'package:livecare/models/form/dataModel/form_field_rule_result_data_model.dart';
import 'package:livecare/models/form/dataModel/sub_form_data_model.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormFieldDataModel {
  String szFieldName = "";
  String szFieldKey = "";
  dynamic anyFieldValue;

  List<FormFieldDataSourceDataModel> arrayDataSource = [];

  List<FormFieldRuleDataModel> arrayFieldRules = [];
  SubFormDataModel? modelSubFormTemplate = SubFormDataModel();

  EnumFormFieldType enumFieldType = EnumFormFieldType.unrecognized;
  EnumFormFieldValueType enumFieldValueType = EnumFormFieldValueType.unrecognized;
  EnumFormFieldAlertType enumAlertType = EnumFormFieldAlertType.unrecognized;

  bool allowMultipleInstances = false; // for sub-forms only

  String szTitleFieldKey = ""; // for sub-forms only

  bool isRequired = true;
  bool isIncludedInReport = true; // for photo-pickers

  dynamic parsedObject;
  bool isVisible = true;

  FormFieldDataModel() {
    initialize();
  }

  initialize() {
    szFieldName = "";
    szFieldKey = "";
    anyFieldValue = null;
    arrayDataSource = [];
    arrayFieldRules = [];
    modelSubFormTemplate = SubFormDataModel();
    enumFieldType = EnumFormFieldType.textField;
    enumFieldValueType = EnumFormFieldValueType.string;
    enumAlertType = EnumFormFieldAlertType.warning;
    allowMultipleInstances = false;
    szTitleFieldKey = "";
    isRequired = false;
    isIncludedInReport = true;
    parsedObject = null;
    isVisible = true;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("name")) {
        szFieldName = UtilsString.parseString(dictionary["name"]);
      }
      if (dictionary.containsKey("key")) {
        szFieldKey = UtilsString.parseString(dictionary["key"]);
      }
      if (dictionary.containsKey("value")) anyFieldValue = dictionary["value"];
      if (dictionary.containsKey("type")) {
        enumFieldType =
            FormFieldTypeExtension.fromString(
                UtilsString.parseString(
                    dictionary["type"]
                )
            );
      }
      //       if (dictionary.containsKey("fieldValueType"))
      //     enumFieldValueType = ISUtilsGeneral.ISEnumFormFieldValueType.fromString(UtilsString.parseString(dictionary["fieldValueType"]));
      // if (dictionary.containsKey("alertType"))
      //     enumAlertType = ISUtilsGeneral.ISEnumFormFieldAlertType.fromString(UtilsString.parseString(dictionary["alertType"]));
      if (dictionary.containsKey("multipleInstances")) {
        allowMultipleInstances =
            UtilsString.parseBool(dictionary["multipleInstances"], false);
      }
      if (dictionary.containsKey("titleKey")) {
        szTitleFieldKey =
            UtilsString.parseString(dictionary["titleKey"]);
      }
      if (dictionary.containsKey("required")) {
        isRequired =
            UtilsString.parseBool(dictionary["required"], false);
      }
      if (dictionary.containsKey("includedInReport")) {
        isIncludedInReport =
            UtilsString.parseBool(dictionary["includedInReport"], true);
      }
      if (dictionary.containsKey("visible")) {
        isVisible =
            UtilsString.parseBool(dictionary["visible"], true);
      }
      if (dictionary.containsKey("dataSources") &&
          dictionary["dataSources"] != null) {
        final List<dynamic> dataSources = dictionary["dataSources"];
        for (int i in Iterable.generate(dataSources.length)) {
          final s = dataSources[i];
          final ds = FormFieldDataSourceDataModel();
          ds.deserializeFromString(s);
          if (ds.isValid()) {
            arrayDataSource.add(ds);
          }
        }
      } else if (dictionary.containsKey("dataSource") &&
          dictionary["dataSource"] != null) {
        final List<dynamic> dataSources = dictionary["dataSource"];
        for (int i in Iterable.generate(dataSources.length)) {
          final Map<String, dynamic> dict = dataSources[i];
          final ds = FormFieldDataSourceDataModel();
          ds.deserializeFromDictionary(dict);
          if (ds.isValid()) {
            arrayDataSource.add(ds);
          }
        }
      }
      if (dictionary.containsKey("rules") && dictionary["rules"] != null) {
        final List<dynamic> jsonFieldRules = dictionary["rules"];
        for (int i in Iterable.generate(jsonFieldRules.length)) {
          final dict = jsonFieldRules[i];
          final ds = FormFieldRuleDataModel();
          ds.deserialize(dict);
          if (ds.isValid()) {
            arrayFieldRules.add(ds);
          }
        }
      }
      if (enumFieldType == EnumFormFieldType.subForm) {
        if (dictionary.containsKey("subForm") &&
            dictionary["subForm"] != null) {
          final Map<String, dynamic> subForm = dictionary["subForm"];
          modelSubFormTemplate?.deserialize(subForm);
          modelSubFormTemplate?.szTitleFieldKey = szTitleFieldKey;
          modelSubFormTemplate?.allowMultipleInstances = allowMultipleInstances;
        }
        if (anyFieldValue is List<dynamic>) {
          final subForms = anyFieldValue as List<dynamic>?;
          final List<SubFormDataModel> array = [];
          for (int i in Iterable.generate(subForms!.length)) {
            final Map<String, dynamic> dict = subForms[i];
            final sb = SubFormDataModel();
            sb.deserialize(dict);
            sb.szTitleFieldKey = szTitleFieldKey;
            sb.allowMultipleInstances = allowMultipleInstances;
            array.add(sb);
          }
          parsedObject = array;
        }
      } else if (enumFieldType == EnumFormFieldType.multiPhotoPicker) {
        final List<MediaDataModel> array = [];
        if (anyFieldValue is List<dynamic>) {
          final media = anyFieldValue as List<dynamic>?;
          for (int i in Iterable.generate(media!.length)) {
            final Map<String, dynamic> jsonObject = media[i];
            final medium = MediaDataModel();
            medium.deserialize(jsonObject);
            if (medium.isValid()) array.add(medium);
          }
        }
        parsedObject = array;
      } else if (enumFieldType == EnumFormFieldType.singlePhotoPicker ||
          enumFieldType == EnumFormFieldType.signature) {
        if (anyFieldValue is Map<String, dynamic>) {
          final jsonMedium = anyFieldValue as Map<String, dynamic>;
          final medium = MediaDataModel();
          medium.deserialize(jsonMedium);
          if (medium.isValid()) parsedObject = medium;
        }
      } else if (enumFieldType == EnumFormFieldType.multiListPicker) {
        if (anyFieldValue is List<dynamic>) {
          final anyValues = anyFieldValue as List<dynamic>;
          final List<String> array = [];
          for (int i in Iterable.generate(anyValues.length)) {
            final strValue = anyValues[i];
            array.add(strValue);
          }
          parsedObject = array;
        } else {
          parsedObject = [];
        }
      } else {
        parsedObject = anyFieldValue;
      }
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
  }

  Map<String, dynamic>? serialize() {
    final Map<String, dynamic> jsonObject = {};
    try {
      jsonObject["name"] = szFieldName;
      jsonObject["key"] = szFieldKey;
      jsonObject["type"] = enumFieldType.value;
      //       jsonObject["fieldValueType"]= enumFieldValueType.toString();
      // jsonObject["alertType"]= enumAlertType.toString();
      jsonObject["includedInReport"] = isIncludedInReport;
      jsonObject["required"] = isRequired;
      jsonObject["visible"] = isVisible;
      if (enumFieldType == EnumFormFieldType.subForm &&
          modelSubFormTemplate != null) {
        jsonObject["subForm"] = modelSubFormTemplate!.serialize();
        jsonObject["multipleInstances"] = allowMultipleInstances;
        jsonObject["titleKey"] = szTitleFieldKey;
      }
      if (parsedObject != null && hasValue()) {
        // Build anyFieldValue
        if (enumFieldType == EnumFormFieldType.multiPhotoPicker) {
          // [ISMediaDataModel]
          final List<MediaDataModel>? media =
          parsedObject as List<MediaDataModel>?;
          if (media != null) {
            final List<dynamic> newValue = [];
            for (int i in Iterable.generate(media.length)) {
              final MediaDataModel m = media[i];
              final Map<String, dynamic> dict = m.serializeForCreateFormMedia();
              dict["id"] = m.id;
              newValue.add(dict);
            }
            anyFieldValue = newValue;
          }
        } else if (enumFieldType == EnumFormFieldType.singlePhotoPicker) {
          final MediaDataModel? medium = parsedObject as MediaDataModel?;
          if (medium != null) {
            final Map<String, dynamic> dict = medium
                .serializeForCreateFormMedia();
            dict["id"] = medium.id;
            anyFieldValue = dict;
          }
        } else if (enumFieldType == EnumFormFieldType.signature) {
          final MediaDataModel? medium = parsedObject as MediaDataModel?;
          if (medium != null) {
            final Map<String, dynamic> dict = medium
                .serializeForCreateFormMedia();
            dict["id"] = medium.id;
            anyFieldValue = dict;
          }
        } else if (enumFieldType == EnumFormFieldType.subForm) {
          final List<SubFormDataModel>? subForms =
          parsedObject as List<SubFormDataModel>?;
          // [ISMediaDataModel]
          if (subForms != null) {
            final List<dynamic> newValue = [];
            for (int i in Iterable.generate(subForms.length)) {
              final SubFormDataModel sb = subForms[i];
              final Map<String, dynamic>? dict = sb.serialize();
              newValue.add(dict);
            }
            anyFieldValue = newValue;
          }
        } else if (enumFieldType == EnumFormFieldType.multiListPicker) {
          // Do not delete. It should be different with iOS version. issued by 2020-02-25 ex : {"value" : "[siding, brick]"}
          if (parsedObject != null) {
            final arrayObjects = parsedObject as List<String>?;
            final List<dynamic> array = [];
            for (var str in arrayObjects!) {
              array.add(str);
            }
            anyFieldValue = array;
          } else {
            anyFieldValue = [];
          }
        } else {
          anyFieldValue = parsedObject;
        }
        jsonObject["value"] = anyFieldValue;
      }
      final List<dynamic> arrDataSource = [];
      for (var ds in arrayDataSource) {
        arrDataSource.add(ds.serializeToString());
      }
      jsonObject["dataSources"] = arrDataSource;
      final List<dynamic> arrFieldRules = [];
      for (var rule in arrayFieldRules) {
        arrFieldRules.add(rule.serialize());
      }
      jsonObject["rules"] = arrFieldRules;
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    return jsonObject;
  }

  bool isValid() {
    return enumFieldType != EnumFormFieldType.unrecognized;
  }

  bool hasValue() {
    if (enumFieldType == EnumFormFieldType.multiPhotoPicker) {
      final List<MediaDataModel>? values = parsedObject as List<
          MediaDataModel>?;
      return (values != null && values.isNotEmpty) ?
      true
          : false;
    } else if (enumFieldType == EnumFormFieldType.singlePhotoPicker ||
        enumFieldType == EnumFormFieldType.signature) {
      final MediaDataModel ? value
      = parsedObject as MediaDataModel?;
      return value != null;
    } else if (enumFieldType == EnumFormFieldType.multiListPicker) {
      final values = parsedObject as List<String>?;
      return values != null && values.isNotEmpty;
    } else if (enumFieldType == EnumFormFieldType.subForm) {
      final List <SubFormDataModel>? values = parsedObject as List<
          SubFormDataModel>?;
      return values != null && values.isNotEmpty;
    } else {
      if (parsedObject is String) {
        final stringValue = parsedObject as String?;
        if (stringValue!.isNotEmpty) return true;
      } else if (parsedObject != null) {
        return true;
      }
    }
    return
      false;
  }

  String? convertObjectToString(dynamic anyValue) {
    if (anyValue == null) return "";
    final str = anyValue.toString();
    return (str.isEmpty || str == "null") ? "" : str;
  }

  List<FormFieldRuleResultDataModel>? generateFieldRulesResult() {
    final List<FormFieldRuleResultDataModel> array = [];
    if (enumFieldType == EnumFormFieldType.subForm) {
      if (modelSubFormTemplate != null) {
        for (var section in modelSubFormTemplate!.arraySections) {
          for (var field in section.arrayFields) {
            array.addAll(field.generateFieldRulesResult()!);
          }
        }
      }
    } else {
      for (var rule in arrayFieldRules) {
        final bool visible = (rule.testValue(parsedObject)) ?
        // Apply "action"
        rule.enumAction == EnumFormFieldRuleAction.show
            :
        // Apply "elseAction"
        rule.enumElseAction == EnumFormFieldRuleAction.show;

        for (var key in rule.arrayTargetKeys) {
          final result = FormFieldRuleResultDataModel();
          result.szFieldKey = key;
          result.isVisible = visible;
          array.add(result);
        }
      }
    }
    return array;
  }

  SubFormDataModel? addNewInstanceForSubForm(String? title) {
    if (parsedObject != null) {
      final List<SubFormDataModel>? parsedObj =
      parsedObject as List<SubFormDataModel>?;

      // Create new
      final SubFormDataModel? newSubForm = modelSubFormTemplate?.cloneModel();
      // set form-title
      newSubForm?.setFormTitle(title!);
      final List<SubFormDataModel> newParsedObject = List.from(parsedObj!.toList());
      newParsedObject.add(newSubForm!);
      parsedObject = newParsedObject;
    } else {
      final SubFormDataModel? newSubForm = modelSubFormTemplate?.cloneModel();

      // set form-title
      newSubForm?.setFormTitle(title!);
      final List<SubFormDataModel> newParsedObject = [];
      newParsedObject.add(newSubForm!);
      parsedObject = newParsedObject;
    }
    return null;
  }

  deleteSubFormAtIndex(int index) {
    if (parsedObject != null) {
      final List<SubFormDataModel>? parsedObj =
      parsedObject as List<SubFormDataModel>?;
      if (index < parsedObj!.length) {
        parsedObj.removeAt(index);
        parsedObject = parsedObj;
      }
    }
  }

  SubFormDataModel? getSubFormDataModelAtIndex(int index) {
    // Create if needed
    if (parsedObject != null) {
      final List<SubFormDataModel>? parsedObj =
      parsedObject as List<SubFormDataModel>?;
      if (parsedObj!.length == index) {
        addNewInstanceForSubForm("");
      } else if (parsedObj.length > index) {
        parsedObj[index];
      } else {
        null;
      }
    } else {
      addNewInstanceForSubForm("");
    }
    return null;
// Following code will never be executed
// return nil
  }
}

enum EnumFormFieldType {
  textField,
  numberField,
  textView,
  formattedField,
  datePicker,
  singleListPicker,
  multiListPicker,
  multiPhotoPicker,
  singlePhotoPicker,
  textLabel,
  signature,
  subForm,
  unrecognized
}

extension FormFieldTypeExtension on EnumFormFieldType {
  static EnumFormFieldType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormFieldType.unrecognized;
    }
    for (var t in EnumFormFieldType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormFieldType.unrecognized;
  }

  String get value {
    switch (this) {
      case EnumFormFieldType.textField:
        return "SingleLineEntryAlpha";
      case EnumFormFieldType.numberField:
        return "SingleLineEntryNumeric";
      case EnumFormFieldType.textView:
        return "MultiLineEntry";
      case EnumFormFieldType.formattedField:
        return "FormattedInput";
      case EnumFormFieldType.datePicker:
        return "DatePicker";
      case EnumFormFieldType.singleListPicker:
        return "ListPicker";
      case EnumFormFieldType.multiListPicker:
        return "MultiListPicker";
      case EnumFormFieldType.multiPhotoPicker:
        return "MultiPhotoPicker";
      case EnumFormFieldType.singlePhotoPicker:
        return "PhotoPicker";
      case EnumFormFieldType.textLabel:
        return "TextLabel";
      case EnumFormFieldType.signature:
        return "SignatureCapture";
      case EnumFormFieldType.subForm:
        return "SubFormPicker";
      case EnumFormFieldType.unrecognized:
        return "";
    }
  }
}

enum EnumFormFieldValueType {
  string,
  integer,
  dateOnly,
  array,
  unComparable,
  unrecognized
}

extension FormFieldValueTypeExtension on EnumFormFieldValueType {
  static EnumFormFieldValueType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormFieldValueType.unrecognized;
    }
    for (var t in EnumFormFieldValueType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormFieldValueType.unrecognized;
  }

  String get value {
    switch (this) {
      case EnumFormFieldValueType.string:
        return "String";
      case EnumFormFieldValueType.integer:
        return "Integer";
      case EnumFormFieldValueType.dateOnly:
        return "DateOnly";
      case EnumFormFieldValueType.array:
        return "Array";
      case EnumFormFieldValueType.unComparable:
        return "Uncomparable";
      case EnumFormFieldValueType.unrecognized:
        return "";
    }
  }
}

enum EnumFormFieldAlertType {
  warning,
  unrecognized
}

extension FormFieldAlertTypeExtension on EnumFormFieldAlertType {
  static EnumFormFieldAlertType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormFieldAlertType.unrecognized;
    }
    for (var t in EnumFormFieldAlertType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormFieldAlertType.unrecognized;
  }

  String get value {
    switch (this) {
      case EnumFormFieldAlertType.warning:
        return "WARNING";
      case EnumFormFieldAlertType.unrecognized:
        return "";
    }
  }
}