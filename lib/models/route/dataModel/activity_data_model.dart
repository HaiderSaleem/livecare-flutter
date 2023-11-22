import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/route/dataModel/instruction_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class ActivityDataModel {
  String id = "";
  LocationDataModel geoLocation = LocationDataModel();
  List<PayloadDataModel> arrayPayloads = [];
  int nWaitTime = 0;
  int nTravelTime = 0;
  DateTime? dateEstimatedArrival;
  DateTime? dateEstimatedDeparture;
  DateTime? dateActualArrival;
  DateTime? dateActualDeparture;
  EnumActivityStatus enumStatus = EnumActivityStatus.none;
  bool outdated = false;
  double fOdometer = 0.0;
  String szOutcome = "";

  /// These 2 date fields are used to re-calculate the most correct arrival / departure times
  /// These field can be updated later by `routes/trip-requests/:id/time` API.

  DateTime? dateBestArrival;
  DateTime? dateBestDeparture;
  bool isStartingDepot = false;
  bool isEndingDepot = false;

  List<LatLng> arrayWaypoints = [];
  List<InstructionDataModel> arrayInstructions = [];

  initialize() {
    id = "";
    geoLocation = LocationDataModel();
    arrayPayloads = [];
    nWaitTime = 0;
    nTravelTime = 0;
    dateEstimatedArrival = null;
    dateEstimatedDeparture = null;
    dateActualArrival = null;
    dateActualDeparture = null;
    enumStatus = EnumActivityStatus.none;
    outdated = false;
    dateBestArrival = null;
    dateBestDeparture = null;
    fOdometer = 0.0;
    szOutcome = "";
    isStartingDepot = false;
    isEndingDepot = false;
    arrayWaypoints = [];
    arrayInstructions = [];
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      id = UtilsString.parseString(dictionary["id"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "waitTime")) {
      nWaitTime = UtilsString.parseInt(dictionary["waitTime"], 0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "travelTime")) {
      nTravelTime = UtilsString.parseInt(dictionary["travelTime"], 0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = ActivityStatusExtension.fromString(
          UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "odometer")) {
      fOdometer = UtilsString.parseDouble(dictionary["odometer"], 0.0);
    }

    dateEstimatedArrival = UtilsDate.getDateTimeFromStringWithFormatFromApi(
        UtilsString.parseString(dictionary["estimatedArrival"]),
        EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
        true);

    dateEstimatedDeparture = UtilsDate.getDateTimeFromStringWithFormatFromApi(
        UtilsString.parseString(dictionary["estimatedArrival"]),
        EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
        true);

    if (UtilsBaseFunction.containsKey(dictionary, "actualArrival")) {
      dateActualArrival = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualArrival"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "actualDeparture")) {
      dateActualDeparture = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualDeparture"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "location")) {
      final Map<String, dynamic> location = dictionary["location"];
      geoLocation.deserialize(location);
    }


    if (UtilsBaseFunction.containsKey(dictionary, "payloads")) {
      final List<dynamic> payloads = dictionary["payloads"];
      for (int i in Iterable.generate(payloads.length)) {
        final Map<String, dynamic> json = payloads[i];
        final payload = PayloadDataModel();
        payload.deserialize(json);
        arrayPayloads.add(payload);
      }
    }


    if (UtilsBaseFunction.containsKey(dictionary, "waypoints")) {
      final List<dynamic> waypoints = dictionary["waypoints"];
      for (int i in Iterable.generate(waypoints.length)) {
        final List<dynamic> coords = waypoints[i];
        if (coords.length == 2) {
          arrayWaypoints.add(LatLng(UtilsString.parseDouble(coords[1], 0.0),
              UtilsString.parseDouble(coords[0], 0.0)));
        }
      }
    }


    if (UtilsBaseFunction.containsKey(dictionary, "instructions")) {
      final List<dynamic> instructions = dictionary["instructions"];
      for (int i in Iterable.generate(instructions.length)) {
        final Map<String, dynamic> json = instructions[i];
        final instruction = InstructionDataModel();
        instruction.deserialize(json);
        arrayInstructions.add(instruction);
      }
    }
  }

  Map<String, dynamic> serializeForUpdateTransportPayloads() {
    final Map<String, dynamic> jsonObject = {};
    final List<dynamic> jsonArray = [];
    for (var payload in arrayPayloads) {
      jsonArray.add(payload.serializeForUpdate());
    }
    jsonObject["payloads"] = jsonArray;
    return jsonObject;
  }

  Map<String, dynamic> serializeForUpdateServicePayloads() {

    final Map<String, dynamic> jsonObject = {};
    final List<dynamic> jsonArray = [];

    for (var payload in arrayPayloads) {
      var dict = payload.serializeForUpdate();
      dict["odometer"] = fOdometer;
      dict["outcome"] = szOutcome;
      jsonArray.add(dict);
    }
    jsonObject["payloads"] = jsonArray;
    return jsonObject;
  }

  invalidate() {
    outdated = true;
  }

  bool isValid() => (id.isNotEmpty && !outdated);

  bool isRouteStart() => arrayPayloads.isEmpty;

  recalculateBestTimes(DateTime datePrev) {
    /// Different calculation for Transport / Service route
    final bool isServiceRoute = (arrayPayloads
        .any((element) => element.enumType == EnumPayloadType.service));

    if (isServiceRoute) {
      if (dateActualArrival != null) {
        dateBestArrival = dateActualArrival;
      } else {
        dateBestArrival = dateEstimatedArrival;
      }

      if (dateActualDeparture != null) {
        dateBestDeparture = dateActualDeparture;
      } else {
        dateBestDeparture = dateEstimatedDeparture;
      }
    } else {
      if (dateActualArrival != null) {
        dateBestArrival = dateActualArrival;
      } else {
        dateBestArrival = UtilsDate.addSecondsToDate(datePrev, nTravelTime);
      }

      if (dateActualDeparture != null) {
        dateBestDeparture = dateActualDeparture;
      } else {
        var totalSeconds = nWaitTime;
        for (var payload in arrayPayloads) {
          totalSeconds += payload.nLoadTime;
        }
        dateBestDeparture = UtilsDate.addSecondsToDate(
            dateBestArrival ?? datePrev, totalSeconds);
      }
    }
  }

  DateTime? getBestArrivalDateTime() => dateBestArrival;

  DateTime? getBestDepartureDateTime() => dateBestDeparture;

  int getPickupCount() {
    int count = 0;
    for (var payload in arrayPayloads) {
      if (payload.enumType == EnumPayloadType.pickup) {
        count += 1;
      }
    }
    return count;
  }

  int getDropOffCount() {
    int count = 0;
    for (var payload in arrayPayloads) {
      if (payload.enumType == EnumPayloadType.delivery) {
        count += 1;
      }
    }
    return count;
  }

  bool isActive() {
    if (enumStatus == EnumActivityStatus.scheduled ||
        enumStatus == EnumActivityStatus.enRoute) {
      return true;
    }
    if (enumStatus == EnumActivityStatus.cancelled) {
      return false;
    }
    // It's marked as Arrived but not confirmed the riders
    for (var payload in arrayPayloads) {
      if (payload.isActive()) {
        return true;
      }
    }
    return false;
  }

  bool isAllNoShow() {
    for (var payload in arrayPayloads) {
      if (payload.enumStatus != EnumPayloadStatus.noShow &&
          payload.enumStatus != EnumPayloadStatus.cancelled) {
        return false;
      }
    }
    return true;
  }

  //Offline Logic
  markAsArrived() {
    final date = UtilsDate.getStringFromDateTimeWithFormat(
        DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    dateActualArrival = UtilsDate.getDateTimeFromStringWithFormatToApi(
        date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    dateActualDeparture = UtilsDate.getDateTimeFromStringWithFormatToApi(
        date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
  }
}

enum EnumActivityStatus { none, scheduled, arrived, enRoute, cancelled }

extension ActivityStatusExtension on EnumActivityStatus {
  static EnumActivityStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumActivityStatus.none;
    }
    for (var t in EnumActivityStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumActivityStatus.none;
  }

  String get value {
    switch (this) {
      case EnumActivityStatus.none:
        return "";
      case EnumActivityStatus.scheduled:
        return "Scheduled";
      case EnumActivityStatus.arrived:
        return "Arrived";
      case EnumActivityStatus.enRoute:
        return "En Route";
      case EnumActivityStatus.cancelled:
        return "Cancelled";
    }
  }
}
