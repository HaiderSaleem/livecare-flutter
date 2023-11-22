import 'package:livecare/models/route/dataModel/transfer_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../../utils/utils_date.dart';

class PayloadDataModel {
  String id = "";
  String requestId = "";
  String szDescription = "";
  EnumPayloadStatus enumStatus = EnumPayloadStatus.none;
  EnumPayloadType enumType = EnumPayloadType.none;
  String cancelReason = "";
  String requestTiming = "";
  DateTime? dateEstimatedArrival;
  int nLoadTime = 0;
  TransferDataModel modelTransfer = TransferDataModel();

  initialize() {
    id = "";
    requestId = "";
    szDescription = "";
    cancelReason = "";
    requestTiming = "";
    dateEstimatedArrival = null;
    enumStatus = EnumPayloadStatus.none;
    enumType = EnumPayloadType.none;
    nLoadTime = 0;
    modelTransfer = TransferDataModel();
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      id = UtilsString.parseString(dictionary["id"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "requestTiming")) {
      requestTiming = UtilsString.parseString(dictionary["requestTiming"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "requestId")) {
      requestId = UtilsString.parseString(dictionary["requestId"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "description")) {
      szDescription = UtilsString.parseString(dictionary["description"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = PayloadTypeExtension.fromString(
          UtilsString.parseString(dictionary["type"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = PayloadStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "loadTime")) {
      nLoadTime = UtilsString.parseInt(dictionary["loadTime"], 0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "transfer")) {
      modelTransfer.deserialize(dictionary["transfer"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "requestTime")) {
      dateEstimatedArrival = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["requestTime"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }

  }

  Map<String, dynamic> serializeForUpdate() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["id"] = id;
    jsonObject["status"] = enumStatus.value;
    jsonObject["cancelReason"] = cancelReason;

    return jsonObject;
  }

  bool isActive() => enumStatus.isActive;
}

enum EnumPayloadType { none, pickup, delivery, service }

extension PayloadTypeExtension on EnumPayloadType {
  static EnumPayloadType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumPayloadType.none;
    }
    for (var t in EnumPayloadType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumPayloadType.none;
  }

  String get value {
    switch (this) {
      case EnumPayloadType.none:
        return "";
      case EnumPayloadType.pickup:
        return "Pickup";
      case EnumPayloadType.delivery:
        return "Delivery";
      case EnumPayloadType.service:
        return "Service";
    }
  }
}

enum EnumPayloadStatus {
  none,
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow
}

extension PayloadStatusExtension on EnumPayloadStatus {
  static EnumPayloadStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumPayloadStatus.none;
    }
    for (var t in EnumPayloadStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumPayloadStatus.none;
  }

  bool get isActive =>
      this == EnumPayloadStatus.scheduled ||
      this == EnumPayloadStatus.inProgress;

  String get value {
    switch (this) {
      case EnumPayloadStatus.none:
        return "";
      case EnumPayloadStatus.scheduled:
        return "Scheduled";
      case EnumPayloadStatus.inProgress:
        return "In Progress";
      case EnumPayloadStatus.completed:
        return "Completed";
      case EnumPayloadStatus.cancelled:
        return "Cancelled";
      case EnumPayloadStatus.noShow:
        return "No Show";
    }
  }
}
