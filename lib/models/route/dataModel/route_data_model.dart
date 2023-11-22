import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/transfer_data_model.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/models/route/dataModel/payload_data_model.dart';
import 'package:livecare/models/route/dataModel/route_outcome_result_data_model.dart';
import 'package:livecare/models/shared/vehicle_ref_data_model.dart';
import 'package:livecare/models/user/dataModel/user_re_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class RouteDataModel extends BaseDataModel {
  String szName = "";
  OrganizationRefDataModel? refOrganization;
  VehicleRefDataModel? refVehicle;
  UserRefDataModel? refDriver;
  List<ActivityDataModel> arrayActivities = [];
  DateTime? dateEstimatedStart;
  DateTime? dateEstimatedCompleted;
  DateTime? dateActualStart;
  DateTime? dateActualCompleted;
  List<FormRefDataModel> arrayPreFormRefs = [];
  List<FormRefDataModel> arrayPostFormRefs = [];
  double fOdometerStart = 0.0;
  double fOdometerEnd = 0.0;
  bool isRequiresOutcome = false;
  List<RouteOutcomeResultDataModel> arrayOutcomeResults = [];
  EnumRouteType enumType = EnumRouteType.transport;
  EnumRouteStatus enumStatus = EnumRouteStatus.none;

  // This property is used to validate / invalidate the Route object. If the object is out-dated, we need to pull the object again
  bool outdated = false;

  // These 2 date fields are used to re-calculate the most correct start / completed times
  DateTime? dateBestStart;
  DateTime? dateBestCompleted;

  @override
  initialize() {
    super.initialize();
    refOrganization = null;
    refVehicle = null;
    refDriver = null;
    arrayActivities = [];
    dateEstimatedStart = null;
    dateEstimatedCompleted = null;
    dateActualStart = null;
    dateActualCompleted = null;
    enumType = EnumRouteType.transport;
    enumStatus = EnumRouteStatus.none;
    outdated = false;
    dateBestStart = null;
    dateBestCompleted = null;
    arrayPreFormRefs = [];
    arrayPostFormRefs = [];
    fOdometerStart = 0.0;
    fOdometerEnd = 0.0;
    isRequiresOutcome = false;
    arrayOutcomeResults = [];
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = RouteTypeExtension.fromString(UtilsString.parseString(dictionary["type"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = RouteStatusExtension.fromString(UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "estimatedStart")) {
      dateEstimatedStart = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["estimatedStart"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "estimatedCompleted")) {
      dateEstimatedCompleted = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["estimatedCompleted"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "actualStart")) {
      dateActualStart = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualStart"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "actualCompleted")) {
      dateActualCompleted = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualCompleted"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "vehicle")) {
      final vehicle = dictionary["vehicle"];
      if (vehicle is Map<String, dynamic>) {
        refVehicle = VehicleRefDataModel();
        refVehicle!.deserialize(vehicle);
      }
    }
    if (UtilsBaseFunction.containsKey(dictionary, "driver")) {
      final driver = dictionary["driver"];
      if (driver is Map<String, dynamic>) {
        refDriver = UserRefDataModel();
        refDriver!.deserialize(driver);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "activities")) {
      final activities = dictionary["activities"];
      if (activities is List<dynamic>) {
        for (int i in Iterable.generate(activities.length)) {
          final activity = ActivityDataModel();
          activity.deserialize(activities[i]);
          arrayActivities.add(activity);
        }
        final firstActivity = arrayActivities.isEmpty ? null : arrayActivities.first;
        if (firstActivity != null) {
          if (firstActivity.arrayPayloads.isEmpty) {
            firstActivity.isStartingDepot = true;
          }
        }
        final lastActivity = arrayActivities.isEmpty ? null : arrayActivities.last;
        if (lastActivity != null && arrayActivities.length > 1) {
          if (lastActivity.arrayPayloads.isEmpty) {
            lastActivity.isEndingDepot = true;
          }
        }
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "preForms")) {
      final preForms = dictionary["preForms"];
      if (preForms is List<dynamic>) {
        for (int i in Iterable.generate(preForms.length)) {
          final form = FormRefDataModel();
          form.deserialize(preForms[i]);
          arrayPreFormRefs.add(form);
        }
      }
    }
    if (UtilsBaseFunction.containsKey(dictionary, "postForms")) {
      final postForms = dictionary["postForms"];
      if (postForms is List<dynamic>) {
        for (int i in Iterable.generate(postForms.length)) {
          final form = FormRefDataModel();
          form.deserialize(postForms[i]);
          arrayPostFormRefs.add(form);
        }
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "transport")) {
      final transport = dictionary["transport"];
      if (transport is Map<String, dynamic>) {
        refOrganization = OrganizationRefDataModel();
        refOrganization!.deserialize(transport);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "odometer")) {
      final odometer = dictionary["odometer"];
      if (odometer is Map<dynamic, dynamic>) {
        fOdometerStart = UtilsString.parseDouble(odometer["start"], 0.0);
        fOdometerEnd = UtilsString.parseDouble(odometer["end"], 0.0);
      }
    }
    recalculateBestTimes();

    if (UtilsBaseFunction.containsKey(dictionary, "requiresOutcome")) {
      isRequiresOutcome = UtilsString.parseBool(dictionary["requiresOutcome"], false);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "outcomeResults")) {
      final List<dynamic> outcomeResults = dictionary["outcomeResults"];
      for (int i in Iterable.generate(outcomeResults.length)) {
        final result = RouteOutcomeResultDataModel();
        result.deserialize(outcomeResults[i]);
        arrayOutcomeResults.add(result);
      }
    }
  }

  Map<String, dynamic> serializeForOutcomeResults() {
    final Map<String, dynamic> jsonObject = {};

    final List<dynamic> jsonArray = [];
    for (var outcome in arrayOutcomeResults) {
      jsonArray.add(outcome.serialize());
    }
    jsonObject["outcomes"] = jsonArray;
    return jsonObject;
  }

  invalidate() {
    outdated = true;
  }

  @override
  bool isValid() {
    return (id.isNotEmpty && enumStatus != EnumRouteStatus.cancelled && !outdated && arrayActivities.isNotEmpty);
  }

  bool isActiveRoute() {
    if (enumStatus == EnumRouteStatus.completed || enumStatus == EnumRouteStatus.cancelled) {
      return false;
    }
    // final yesterday = UtilsDate.addDaysToDate(DateTime.now(), -1);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final estimatedComplete = dateEstimatedCompleted;
    if (estimatedComplete != null) {
      if (estimatedComplete.isBefore(yesterday)) {
        return false;
      }
    } else {
      final lastActivity = arrayActivities.isEmpty ? null : arrayActivities.last;
      final estimatedArrival = lastActivity?.dateEstimatedArrival;
      if (lastActivity != null && estimatedArrival != null) {
        if (estimatedArrival.isBefore(yesterday)) {
          return false;
        }
      }
    }
    return true;
  }

  bool isStartRoute() {
    Duration diff;
    try {
      diff = dateEstimatedStart!.difference(DateTime.now());
    } on Exception {
      return false;
    }
    if (diff.inHours <= 2) {
      return true;
    }
    return false;
  }

  bool isFutureRoute() {
    // if(kDebugMode){
    //   return false;
    // }
    // if(kReleaseMode){
    //   return false;
    // }
    if (!isActiveRoute()) {
      return false;
    }
    final dateStart = dateEstimatedStart;
    if (dateStart == null) return false;
    return DateTime.now().isBefore(UtilsDate.addMinutesToDate(dateEstimatedStart!, -90));
  }

  bool isCompleted() => enumStatus == EnumRouteStatus.completed;

  /// Route is technically completed but should ask feedback / outcome-result to officially complete
  bool shouldAskOutcome() {
    if (enumStatus == EnumRouteStatus.completed) {
      return false;
    }
    for (var activity in arrayActivities) {
      if (activity.enumStatus == EnumActivityStatus.scheduled ||
          activity.enumStatus == EnumActivityStatus.enRoute) {
        return false;
      }
      for (var payload in activity.arrayPayloads) {
        if (payload.isActive() == true) {
          return false;
        }
      }
    }
    return isRequiresOutcome;
  }


  /// Route is technically completed but should ask driver to submit post-forms to officially complete
  bool shouldAskPostForms() {
    if (enumStatus == EnumRouteStatus.completed) {
      return false;
    }
    for (var activity in arrayActivities) {
      if (activity.enumStatus == EnumActivityStatus.scheduled || activity.enumStatus
          == EnumActivityStatus.enRoute) {
        return false;
      }

      for (var payload in activity.arrayPayloads) {
        if (payload.isActive()) return false;
      }
    }

    for (var form in arrayPostFormRefs) {
      if (form.submissionId.isEmpty) return true;
    }

    return false;
  }

  // Route is technically completed, and ready to be officially completed
  bool isReadyToComplete() {
    if (enumStatus == EnumRouteStatus.completed || enumStatus == EnumRouteStatus.cancelled) {
      return false;
    }
    if (shouldAskOutcome() || shouldAskPostForms()) {
      return false;
    }
    for (var activity in arrayActivities) {
      if (activity.enumStatus == EnumActivityStatus.scheduled || activity.enumStatus == EnumActivityStatus.enRoute) {
        return false;
      }
      for (var payload in activity.arrayPayloads) {
        if (payload.isActive()) {
          return false;
        }
      }
    }
    return true;
  }


  /// Recalculates Route.start / completed, Activities.arrival / departure times
  /// Attention: This is for Transport only
  recalculateBestTimes() {
    // Route > Start Time
    dateBestStart = dateActualStart ?? dateEstimatedStart;
    var datePrev = dateBestStart ?? DateTime.now();
    for (var activity in arrayActivities) {
      activity.recalculateBestTimes(datePrev = datePrev);
      datePrev = activity.getBestDepartureDateTime() ?? datePrev;
    }
    dateBestCompleted = datePrev;
  }


  DateTime? getBestStartDateTimeForRoute() => dateEstimatedStart;

  DateTime? getBestCompletedTimeForRoute() => dateEstimatedStart;

  String getVehicleName() {
    final vehicle = refVehicle;
    if (vehicle == null) return "N/A";
    if (vehicle.szName.isNotEmpty) {
      return vehicle.szName;
    }
    return "N/A";
  }

  ActivityDataModel? getFirstActivity() {
    // First Activity is always Route-Start, where the vehicle stopped last night or in the prev route
    if (enumType == EnumRouteType.service) {
      return arrayActivities[0];
    }
    if (arrayActivities.length < 2) {
      return null;
    }
    return arrayActivities[1];
  }

  int getRidersCount() {
    var count = 0;
    for (var activity in arrayActivities) {
      count += activity.arrayPayloads.length;
    }
    return count ~/ 2;
  }

  int? getIndexForNextActivityToStartRide() {
    if (isCompleted() || shouldAskOutcome() || shouldAskPostForms()) {
      return null;
    }
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.isActive()) {
        return index;
      }
      index += 1;
    }
    return null;
  }

  int? getIndexForActivityById(String activityId) {
    int index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == activityId) {
        return index;
      }
      index += 1;
    }
    return null;
  }

  String? getIdForNextActivityToStartRide() {
    if (isCompleted() || shouldAskOutcome() || shouldAskPostForms()) {
      return null;
    }
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.isActive()) {
        return activity.id;
      }
    }
    return null;
  }

  bool isRouteForBetweenDates(DateTime startDate, DateTime endDate) {
    final szStartOfDay = UtilsDate.getDateTimeFromStringWithFormatToApi(UtilsString.parseString("%@T00:00:00"), EnumDateTimeFormat.yyyyMMdd.value, true);

    final szEndOfDay = UtilsDate.getDateTimeFromStringWithFormatToApi(UtilsString.parseString("%@T23:59:59"), EnumDateTimeFormat.yyyyMMdd.value, true);
    final startOfDay =
        UtilsDate.getDateTimeFromStringWithFormatToApi(UtilsString.parseString(szStartOfDay), EnumDateTimeFormat.yyyyMMdd.value, true) ?? startDate;

    final endOfDay = UtilsDate.getDateTimeFromStringWithFormatToApi(UtilsString.parseString(szEndOfDay), EnumDateTimeFormat.yyyyMMdd.value, true) ?? endDate;

    final bestStartDate = dateBestStart;
    if (bestStartDate != null) {
      if ((bestStartDate.isAfter(startOfDay) || bestStartDate.isAtSameMomentAs(startOfDay)) &&
          (bestStartDate.isBefore(endOfDay) || bestStartDate.isAtSameMomentAs(endOfDay))) {
        return true;
      }
    }
    final bestEndDate = dateBestCompleted;
    if (bestEndDate != null) {
      if ((bestEndDate.isAfter(startOfDay) || bestEndDate.isAtSameMomentAs(startOfDay)) &&
          (bestEndDate.isBefore(endOfDay) || bestEndDate.isAtSameMomentAs(endOfDay))) {
        return true;
      }
    }
    return false;
  }

  String? getTripRequestIdForTransfer(String transferId) {
    for (var activity in arrayActivities) {
      for (var payload in activity.arrayPayloads) {
        if (payload.modelTransfer.transferId == transferId) {
          return payload.requestId;
        }
      }
    }
    return null;
  }

  PayloadDataModel? getPayloadByConsumerId(String consumerId) {
    for (var activity in arrayActivities) {
      for (var payload in activity.arrayPayloads) {
        if (payload.modelTransfer.enumType == EnumTransferType.consumer && payload.modelTransfer.transferId == consumerId) {
          return payload;
        }
      }
    }
    return null;
  }

  //Offline Logic
  onStartRoute() {
    final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    enumStatus = EnumRouteStatus.enRoute;
    dateActualStart = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    arrayActivities[0].enumStatus = EnumActivityStatus.arrived;
    final index = getIndexForNextActivityToStartRide();
    if (index == null) return;
    arrayActivities[index].enumStatus = EnumActivityStatus.enRoute;
  }

  onStartServiceRoute() {
    final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    final activity = arrayActivities.first;
    final payload = activity.arrayPayloads.first;
    dateActualStart = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    activity.dateActualArrival = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    payload.enumStatus = EnumPayloadStatus.inProgress;
    activity.enumStatus = EnumActivityStatus.arrived;
    enumStatus = EnumRouteStatus.inProgress;
    dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
  }

  onMarkAsArrived(ActivityDataModel currentActivity) {
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == currentActivity.id) {
        currentActivity.markAsArrived();
        currentActivity.enumStatus = EnumActivityStatus.arrived;
        arrayActivities[index] = currentActivity;
      }
      index += 1;
    }
  }

  onUpdatePayloads(ActivityDataModel currentActivity) {
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == currentActivity.id) {
        arrayActivities[index] = currentActivity;
      }
      index += 1;
    }
  }

  onUpdateServicePayloads(ActivityDataModel currentActivity) {
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == currentActivity.id) {
        final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        currentActivity.dateActualDeparture = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        final payload = currentActivity.arrayPayloads.first;
        payload.enumStatus = EnumPayloadStatus.completed;
        arrayActivities[index] = currentActivity;
      }
      index += 1;
    }
    final nextIndex = getIndexForNextActivityToStartRide();
    if (nextIndex == null) return;
    arrayActivities[nextIndex].enumStatus = EnumActivityStatus.enRoute;
  }

  onStartRide(ActivityDataModel currentActivity, EnumActivityStatus enumStatus) {
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == currentActivity.id) {
        currentActivity.enumStatus = enumStatus;
        arrayActivities[index] = currentActivity;
      }
      index += 1;
    }
  }

  onStartServiceRide(ActivityDataModel currentActivity, EnumActivityStatus enumStatus) {
    var index = 0;
    for (var activity in arrayActivities) {
      if (activity.id == currentActivity.id) {
        final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        currentActivity.dateActualArrival = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
        currentActivity.enumStatus = enumStatus;
        final payload = currentActivity.arrayPayloads.first;
        payload.enumStatus = EnumPayloadStatus.inProgress;
        arrayActivities[index] = currentActivity;
      }
      index += 1;
    }
  }

  onCompleteRoute() {
    final date = UtilsDate.getStringFromDateTimeWithFormat(DateTime.now(), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    dateActualCompleted = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    dateUpdatedAt = UtilsDate.getDateTimeFromStringWithFormatToApi(date, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    enumStatus = EnumRouteStatus.completed;
  }
}

enum EnumRouteStatus { none, scheduled, enRoute, inProgress, completed, cancelled }

extension RouteStatusExtension on EnumRouteStatus {
  static EnumRouteStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumRouteStatus.none;
    }
    for (var t in EnumRouteStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumRouteStatus.none;
  }

  String get value {
    switch (this) {
      case EnumRouteStatus.none:
        return "";
      case EnumRouteStatus.scheduled:
        return "Scheduled";
      case EnumRouteStatus.enRoute:
        return "En Route";
      case EnumRouteStatus.inProgress:
        return "In Progress";
      case EnumRouteStatus.completed:
        return "Completed";
      case EnumRouteStatus.cancelled:
        return "Cancelled";
    }
  }
}

enum EnumRouteType { none, transport, shuttle, service }

extension RouteTypeExtension on EnumRouteType {
  static EnumRouteType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumRouteType.none;
    }
    for (var t in EnumRouteType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumRouteType.none;
  }

  String get value {
    switch (this) {
      case EnumRouteType.none:
        return "";
      case EnumRouteType.transport:
        return "Transport";
      case EnumRouteType.shuttle:
        return "Shuttle";
      case EnumRouteType.service:
        return "Service";
    }
  }
}
