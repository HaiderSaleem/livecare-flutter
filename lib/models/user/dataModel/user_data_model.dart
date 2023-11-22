import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_user_data_model.dart';
import 'package:livecare/models/shared/companion_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class UserDataModel extends BaseDataModel {
  List<OrganizationUserDataModel> arrayOrganizations = [];
  String szName = "";
  String szUsername = "";
  String szPhone = "";
  String szEmail = "";
  String szHeroUri = "";
  String szPhoto = "";
  String szPassword = "";
  Uri? profileUrl;

  bool isNotifyByEmail = false;
  bool isNotifyByMessage = false;
  bool isNotifyBySMS = false;

  List<CompanionDataModel> arrayCompanions = [];

  String szDeviceToken = "";
  EnumUserStatus enumStatus = EnumUserStatus.active;

  @override
  initialize() {
    super.initialize();

    arrayOrganizations = [];
    szName = "";
    szUsername = "";
    szPhone = "";
    szEmail = "";
    szHeroUri = "";
    szPhoto = "";
    szPassword = "";

    isNotifyByEmail = false;
    isNotifyByMessage = false;
    isNotifyBySMS = false;

    arrayCompanions = [];

    szDeviceToken = "";
    enumStatus = EnumUserStatus.active;
  }

  Map<String, dynamic> serializeForLocalstorage() {
    return {"id": id, "email": szEmail, "password": szPassword, "photo": szPhoto};
  }

  deserializeFromLocalstorage(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    id = UtilsString.parseString(dictionary["id"]);
    szEmail = UtilsString.parseString(dictionary["email"]);
    szPassword = UtilsString.parseString(dictionary["password"]);
    szPhoto = UtilsString.parseString(dictionary["photo"]);
    profileUrl = (szPhoto != null ? Uri.parse(szPhoto) : null)!;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "username")) {
      szUsername = UtilsString.parseString(dictionary["username"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "email")) {
      szEmail = UtilsString.parseString(dictionary["email"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "heroUri")) {
      szHeroUri = UtilsString.parseString(dictionary["heroUri"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")) {
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "phone")) {
      szPhone = UtilsString.parseString(dictionary["phone"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "deviceToken")) {
      szDeviceToken = UtilsString.parseString(dictionary["deviceToken"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "notifyByEmail")) {
      isNotifyByEmail = UtilsString.parseBool(dictionary["notifyByEmail"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "notifyByMessage")) {
      isNotifyByMessage = UtilsString.parseBool(dictionary["notifyByMessage"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "notifyBySMS")) {
      isNotifyBySMS = UtilsString.parseBool(dictionary["notifyBySMS"], false);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = UserStatusExtension.fromString(UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "organizations")) {
      final List<dynamic> organizations = dictionary["organizations"];
      for (int i in Iterable.generate(organizations.length)) {
        final Map<String, dynamic> dict = organizations[i];
        final org = OrganizationUserDataModel();
        org.deserialize(dict);
        if (org.isValid()) arrayOrganizations.add(org);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "notifications")) {
      final Map<String, dynamic> notification = dictionary["notifications"];
      if (UtilsBaseFunction.containsKey(notification, "sms")) {
        isNotifyBySMS = UtilsString.parseBool(notification["sms"], false);
      }
      if (UtilsBaseFunction.containsKey(notification, "email")) {
        isNotifyByEmail = UtilsString.parseBool(notification["email"], false);
      }
      if (UtilsBaseFunction.containsKey(notification, "message")) {
        isNotifyByMessage = UtilsString.parseBool(notification["message"], false);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "companions")) {
      final List<dynamic> companions = dictionary["companions"];
      for (int i in Iterable.generate(companions.length)) {
        final Map<String, dynamic> dict = companions[i];
        final comp = CompanionDataModel();
        comp.deserialize(dict);
        if (comp.isValid()) arrayCompanions.add(comp);
      }
    }
  }

  @override
  bool isValid() {
    return (id != "" && enumStatus == EnumUserStatus.active);
  }

  List<String> getRegionsByOrganizationId(String organizationId) {
    for (var orgRef in arrayOrganizations) {
      if (orgRef.organizationId == organizationId) {
        return orgRef.arrayRegions;
      }
    }
    return [];
  }

  EnumOrganizationUserRole getRoleByOrganizationId(String organizationId) {
    for (var orgRef in arrayOrganizations) {
      if (orgRef.organizationId == organizationId) {
        return orgRef.enumRole;
      }
    }
    return EnumOrganizationUserRole.caregiver;
  }

  EnumOrganizationUserRole getPrimaryRole() {
    for (var orgRef in arrayOrganizations) {
      if (orgRef.isValid()) return orgRef.enumRole;
    }
    return EnumOrganizationUserRole.caregiver;
  }

  OrganizationUserDataModel? getPrimaryOrganization() {
    return arrayOrganizations.isNotEmpty ? arrayOrganizations.first : null;
  }

  List<OrganizationUserDataModel> getOrganizations() {
    return arrayOrganizations;
  }

  OrganizationUserDataModel? getOrganizationByName(String name) {
    return arrayOrganizations.firstWhere((element) => element.szName == name);
  }
}

enum EnumUserStatus { active, deleted }

extension UserStatusExtension on EnumUserStatus {
  static EnumUserStatus fromString(String? status) {
    if (status == null || status == "") return EnumUserStatus.active;
    if (status.toLowerCase() == EnumUserStatus.active.value.toLowerCase()) {
      return EnumUserStatus.active;
    }
    if (status.toLowerCase() == EnumUserStatus.deleted.value.toLowerCase()) {
      return EnumUserStatus.deleted;
    }
    return EnumUserStatus.active;
  }

  String get value {
    switch (this) {
      case EnumUserStatus.active:
        return "Active";
      case EnumUserStatus.deleted:
        return "Deleted";
    }
  }
}
