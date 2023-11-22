import 'package:livecare/models/form/dataModel/form_configuration_data_model.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_general.dart';
import 'package:livecare/utils/utils_string.dart';

class FormDefinitionDataModel {
  String id = "";
  String organizationId = "";
  String szName = "";
  FormConfigurationDataModel modelConfiguration = FormConfigurationDataModel();
  EnumFormDefinitionStatus enumStatus = EnumFormDefinitionStatus.active;

  DateTime? dateCreatedAt;
  DateTime? dateUpdatedAt;
  Map<String, dynamic> payload = {};

  FormDefinitionDataModel() {
    initialize();
  }

  initialize() {
    id = "";
    organizationId = "";
    szName = "";
    modelConfiguration = FormConfigurationDataModel();
    dateCreatedAt = null;
    dateUpdatedAt = null;
    enumStatus = EnumFormDefinitionStatus.active;
    payload = {};
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    try {
      if (dictionary.containsKey("id")) {
        id = UtilsString.parseString(dictionary["id"]);
      }
      if (dictionary.containsKey("organizationId")) {
        organizationId = UtilsString.parseString(dictionary["organizationId"]);
      }
      if (dictionary.containsKey("name")) {
        szName = UtilsString.parseString(dictionary["name"]);
      }
      if (dictionary.containsKey("formConfiguration") &&
          dictionary["formConfiguration"] != null) {
        final Map<String, dynamic> config = dictionary["formConfiguration"];
        modelConfiguration.deserialize(config);
      }
      if (dictionary.containsKey("createdAt")) {
        dateCreatedAt = UtilsDate.getDateTimeFromStringWithFormatFromApi(
            UtilsString.parseString(dictionary["createdAt"]),
            EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
            true);
      }
      if (dictionary.containsKey("updatedAt")) {
        dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatFromApi(
            UtilsString.parseString(dictionary["updatedAt"]),
            EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
            true);
      }
      if (dictionary.containsKey("status")) {
        enumStatus = FormDefinitionStatusExtension.fromString(
            UtilsString.parseString(dictionary["status"]));
      }
    } catch (e) {
      UtilsGeneral.log("response: " + e.toString());
    }
    payload = dictionary;
  }

  Map<String, dynamic>? serializeForOffline() {
    return payload;
  }

  bool isValid() {
    return id.isNotEmpty && modelConfiguration.isValid();
  }
}

enum EnumFormDefinitionStatus { active, deactive }

extension FormDefinitionStatusExtension on EnumFormDefinitionStatus {
  static EnumFormDefinitionStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumFormDefinitionStatus.active;
    }
    for (var t in EnumFormDefinitionStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumFormDefinitionStatus.active;
  }

  String get value {
    switch (this) {
      case EnumFormDefinitionStatus.active:
        return "Active";
      case EnumFormDefinitionStatus.deactive:
        return "Deactive";
    }
  }
}
