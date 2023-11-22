
import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class InviteDataModel extends BaseDataModel {
  String organizationId = "";
  String organizationName = "";
  String token = "";
  String szToEmail = "";
  EnumOrganizationUserRole enumRole = EnumOrganizationUserRole.caregiver;
  EnumInvitationStatus enumStatus = EnumInvitationStatus.accepted;

  @override
  initialize() {
    super.initialize();
    organizationId = "";
    organizationName = "";
    token = "";
    szToEmail = "";
     enumRole = EnumOrganizationUserRole.caregiver;
    enumStatus = EnumInvitationStatus.accepted;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if(UtilsBaseFunction.containsKey(dictionary, "organizationId")) {
      organizationId = UtilsString.parseString(dictionary["organizationId"]);
    }
    if(UtilsBaseFunction.containsKey(dictionary, "organizationName")) {
      organizationName = UtilsString.parseString(dictionary["organizationName"]);
    }
    if(UtilsBaseFunction.containsKey(dictionary, "token")) {
      token = UtilsString.parseString(dictionary["token"]);
    }
    if(UtilsBaseFunction.containsKey(dictionary, "toEmail")) {
      szToEmail = UtilsString.parseString(dictionary["toEmail"]);
    }
    if(UtilsBaseFunction.containsKey(dictionary, "role")) {
      enumRole = OrganizationUserRoleExtension.fromString(
        UtilsString.parseString(dictionary["role"]));
    }

    if(UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = InvitationStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }
  }

}

enum EnumInvitationStatus {
  pending,
  accepted,
  declined,
  deleted,

}

extension InvitationStatusExtension on EnumInvitationStatus {
  static EnumInvitationStatus fromString(String? type) {
    if (type == null || type == "") return EnumInvitationStatus.pending;

    if (type.toLowerCase() ==
        EnumInvitationStatus.pending.value.toLowerCase()) {
      return EnumInvitationStatus.pending;
    }
    if (type.toLowerCase() ==
        EnumInvitationStatus.accepted.value.toLowerCase()) {
      return EnumInvitationStatus.accepted;
    }
    if (type.toLowerCase() ==
        EnumInvitationStatus.declined.value.toLowerCase()) {
      return EnumInvitationStatus.declined;
    }
    if (type.toLowerCase() ==
        EnumInvitationStatus.deleted.value.toLowerCase()) {
      return EnumInvitationStatus.deleted;
    }
    return EnumInvitationStatus.pending;
  }

  String get value {
    switch (this) {
      case EnumInvitationStatus.pending:
        return "Pending";
      case EnumInvitationStatus.accepted:
        return "Accepted";
      case EnumInvitationStatus.declined:
        return "Declined";
      case EnumInvitationStatus.deleted:
        return "Deleted";

    }
  }
}

