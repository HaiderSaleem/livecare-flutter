import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/models/request/dataModel/request_ref_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class ScheduleDataModel extends RequestDataModel {
  bool isRoundTrip = false;
  DateTime? dateReturn;
  bool isReturnTbd = false;
  DateTime? dateEnd;
  bool isSunday = false;
  bool isMonday = false;
  bool isTuesday = false;
  bool isWednesday = false;
  bool isThursday = false;
  bool isFriday = false;
  bool isSaturday = false;
  EnumRequestTiming enumReturnTiming = EnumRequestTiming.arriveBy;
  EnumRequestRecurringType enumRecurringType = EnumRequestRecurringType.none;
  List<RequestRefDataModel> arrayRequestRefs = [];

  @override
  initialize() {
    super.initialize();
    dateTime = null;
    nEstimatedMiles = 0;

    isRoundTrip = false;
    dateReturn = null;
    isReturnTbd = false;
    dateEnd = null;

    isSunday = false;
    isMonday = false;
    isTuesday = false;
    isWednesday = false;
    isThursday = false;
    isFriday = false;
    isSaturday = false;

    enumReturnTiming = EnumRequestTiming.arriveBy;
    enumRecurringType = EnumRequestRecurringType.none;

    refOrganization = OrganizationRefDataModel();
    refTransportOrganization = OrganizationRefDataModel();
    refLocation = LocationDataModel();

    arrayTransfers = [];
    arrayRequestRefs = [];

    outdated = false;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "return")) {
      dateReturn = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["return"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "end")) {
      dateEnd = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["end"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "tbd")) {
      isTbd = UtilsString.parseBool(dictionary["tbd"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "returnTbd")) {
      isReturnTbd = UtilsString.parseBool(dictionary["returnTbd"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "roundTrip")) {
      isRoundTrip = UtilsString.parseBool(dictionary["roundTrip"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "sun")) {
      isSunday = UtilsString.parseBool(dictionary["sun"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "mon")) {
      isMonday = UtilsString.parseBool(dictionary["mon"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "tue")) {
      isTuesday = UtilsString.parseBool(dictionary["tue"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "wed")) {
      isWednesday = UtilsString.parseBool(dictionary["wed"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "thu")) {
      isThursday = UtilsString.parseBool(dictionary["thu"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "fri")) {
      isFriday = UtilsString.parseBool(dictionary["fri"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "sat")) {
      isSaturday = UtilsString.parseBool(dictionary["sat"], false);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "recurringType")) {
      enumRecurringType = RequestRecurringTypeExtension.fromString(
          UtilsString.parseString(dictionary["recurringType"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "requests")) {
      final List<dynamic> requests = dictionary["requests"];
      for (int i in Iterable.generate(requests.length)) {
        final dict = requests[i];
        final r = RequestRefDataModel();
        r.deserialize(dict);
        arrayRequestRefs.add(r);
      }
    }
  }

  @override
  Map<String, dynamic> serializeForCreateService() {
    final Map<String, dynamic> results = super.serializeForCreateService();
    results["time"] = UtilsDate.getStringFromDateTimeWithFormatToApi(
        dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    results["type"] = EnumRequestType.outOfOffice.value;
    results["description"] = szDescription;
    results["duration"] = intDuration;
    // if (enumType == EnumRequestType.outOfOffice) {
    final Map<String, dynamic> org = {};
    org["organizationId"] = refOrganization.organizationId;
    results["organization"] = org;
    // }

    return _serializeForCreate(results);
  }

  @override
  Map<String, dynamic> serializeForCreateTransport() {
    final Map<String, dynamic> results = super.serializeForCreateTransport();
    results["returnTiming"] = enumReturnTiming.value;
    results["roundTrip"] = isRoundTrip;
    results["returnTbd"] = isReturnTbd;
    results["return"] = UtilsDate.getStringFromDateTimeWithFormatToApi(
        dateReturn, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    return _serializeForCreate(results);
  }

  Map<String, dynamic> _serializeForCreate(Map<String, dynamic> results) {
    results["sun"] = isSunday;
    results["mon"] = isMonday;
    results["tue"] = isTuesday;
    results["wed"] = isWednesday;
    results["thu"] = isThursday;
    results["fri"] = isFriday;
    results["sat"] = isSaturday;
    results["end"] = UtilsDate.getStringFromDateTimeWithFormat(
        dateEnd, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    if (enumRecurringType != EnumRequestRecurringType.none) {
      results["recurringType"] = enumRecurringType.value;
    }

    return results;
  }

  @override
  Map<String, dynamic> serializeForUpdateService() {
    final Map<String, dynamic> results = {};
    results["time"] = UtilsDate.getStringFromDateTimeWithFormatToApi(
        dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, false);
    return results;
  }
}

enum EnumRequestRecurringType { none, weekly }

extension RequestRecurringTypeExtension on EnumRequestRecurringType {
  static EnumRequestRecurringType fromString(String? status) {
    if (status == null || status.isEmpty) return EnumRequestRecurringType.none;
    if (status == EnumRequestRecurringType.none.value) {
      return EnumRequestRecurringType.none;
    }
    if (status == EnumRequestRecurringType.weekly.value) {
      return EnumRequestRecurringType.weekly;
    }
    return EnumRequestRecurringType.none;
  }

  String get value {
    switch (this) {
      case EnumRequestRecurringType.none:
        return "";
      case EnumRequestRecurringType.weekly:
        return "Weekly";
    }
  }
}
