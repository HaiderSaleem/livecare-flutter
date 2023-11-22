import 'package:livecare/models/organization/dataModel/organization_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class OrganizationRefDataModel {
  String organizationId = "";
  String szName = "";
  String szPhoto = "";
  String szPhone = "";
  EnumOrganizationStatus enumStatus = EnumOrganizationStatus.active;

  List<String> arrayRegions = [];

  initialize() {
    organizationId = "";
    szName = "";
    szPhoto = "";
    szPhone = "";
    enumStatus = EnumOrganizationStatus.active;
    arrayRegions = [];
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "organizationId")) {
      organizationId = UtilsString.parseString(dictionary["organizationId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")) {
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = OrganizationStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "regions")) {
      final List<dynamic> regions = dictionary["regions"];
      for (int i in Iterable.generate(regions.length)) {
        final region = UtilsString.parseString(regions[i]);
        arrayRegions.add(region);
      }
    }
  }

  bool isValid() {
    return (enumStatus == EnumOrganizationStatus.active);
  }
}

enum EnumOrganizationUserRole {
  administrator,
  caregiver,
  driver,
  pm,
  guardian,
  dispatch,
  leadDSP
}

extension OrganizationUserRoleExtension on EnumOrganizationUserRole {
  static EnumOrganizationUserRole fromString(String? status) {
    if (status == null || status == "") {
      return EnumOrganizationUserRole.caregiver;
    }
    for (EnumOrganizationUserRole t in EnumOrganizationUserRole.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumOrganizationUserRole.caregiver;
  }

  String get value {
    switch (this) {
      case EnumOrganizationUserRole.administrator:
        return "Administrator";
      case EnumOrganizationUserRole.caregiver:
        return "User";
      case EnumOrganizationUserRole.driver:
        return "Driver";
      case EnumOrganizationUserRole.pm:
        return "PM";
      case EnumOrganizationUserRole.guardian:
        return "Guardian";
      case EnumOrganizationUserRole.dispatch:
        return "Dispatch";
      case EnumOrganizationUserRole.leadDSP:
        return "Lead";
    }
  }
}
