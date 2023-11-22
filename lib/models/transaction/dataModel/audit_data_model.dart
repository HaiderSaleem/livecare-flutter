import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/base/media_data_model.dart';
import 'package:livecare/models/user/dataModel/user_re_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class AuditDataModel extends BaseDataModel {
  double fBalance = 0.0;
  double fDiscrepancy = 0.0;
  DateTime? dateAudit;

  MediaDataModel? modelSnapshot;
  UserRefDataModel refUser = UserRefDataModel();
  EnumAuditStatus enumStatus = EnumAuditStatus.closed;
  bool isOverride = false;

  @override
  initialize() {
    super.initialize();
    fBalance = 0.0;
    fDiscrepancy = 0.0;
    dateAudit = null;
    modelSnapshot = null;
    refUser = UserRefDataModel();
    enumStatus = EnumAuditStatus.closed;
    isOverride = false;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "balance")) {
      fBalance = UtilsString.parseDouble(dictionary["balance"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "discrepancy")) {
      fDiscrepancy = UtilsString.parseDouble(dictionary["discrepancy"], 0.0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "dateAudit")) {
      dateAudit = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["dateAudit"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus =
          AuditStatusExtension.fromString(UtilsString.parseString("status"));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "snapshot")) {
      final Map<String, dynamic> snapshot = dictionary["snapshot"];
      modelSnapshot = MediaDataModel();
      modelSnapshot!.deserialize(snapshot);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "user")) {
      final Map<String, dynamic> user = dictionary["user"];
      refUser.deserialize(user);
    }
  }

  Map<String, dynamic> serializeForAudit() {
    final Map<String, dynamic> result = {};
    result["balance"] = fBalance;

    if (isOverride == true) result["override"] = true;
    return result;
  }
}

enum EnumAuditStatus { closed, open }

extension AuditStatusExtension on EnumAuditStatus {
  static EnumAuditStatus fromString(String? type) {
    if (type == null || type == "") return EnumAuditStatus.closed;

    if (type.toLowerCase() == EnumAuditStatus.open.value.toLowerCase()) {
      return EnumAuditStatus.open;
    }
    if (type.toLowerCase() == EnumAuditStatus.closed.value.toLowerCase()) {
      return EnumAuditStatus.closed;
    }
    return EnumAuditStatus.closed;
  }

  String get value {
    switch (this) {
      case EnumAuditStatus.closed:
        return "Closed";
      case EnumAuditStatus.open:
        return "Open";
    }
  }
}
