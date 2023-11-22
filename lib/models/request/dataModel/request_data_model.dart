import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/consumer/dataModel/consumer_data_model.dart';
import 'package:livecare/models/form/dataModel/form_ref_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/task_data_model.dart';
import 'package:livecare/models/request/dataModel/transfer_data_model.dart';
import 'package:livecare/models/route/dataModel/route_ref_data_model.dart';
import 'package:livecare/models/shared/geo_point_data_model.dart';
import 'package:livecare/models/user/dataModel/user_re_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

import '../../consumer/dataModel/consumer_ref_data_model.dart';
import 'location_data_model.dart';

class RequestDataModel extends BaseDataModel {
  String scheduleId = "";
  OrganizationRefDataModel refOrganization = OrganizationRefDataModel();
  OrganizationRefDataModel refTransportOrganization = OrganizationRefDataModel();
  LocationDataModel refLocation = LocationDataModel();
  GeoPointDataModel refPickup = LocationDataModel();
  GeoPointDataModel refDelivery = LocationDataModel();
  ConsumerRefDataModel refConsumer = ConsumerRefDataModel();
  UserRefDataModel refUser = UserRefDataModel();

  String routeId = "";
  String szRecordLocator = "";
  String szAssignmentType = "";

  String szMessage = "";
  String szOutcome = "";

  int intDuration = 0;

  bool isTbd = false;
  DateTime? dateTime;
  int nEstimatedMiles = 0;
  bool isReturn = false;

  EnumRequestType enumType = EnumRequestType.transport;
  EnumRequestTiming enumTiming = EnumRequestTiming.arriveBy;
  EnumRequestStatus enumStatus = EnumRequestStatus.requested;
  EnumRequestBillingCategoryType enumBillingCategory = EnumRequestBillingCategoryType.none;

  List<TransferDataModel> arrayTransfers = [];
  List<TaskDataModel> arrayTasks = [];

  List<FormRefDataModel> arrayForms = [];
  RouteRefDataModel refRoute = RouteRefDataModel();
  String szDescription = "";

  bool isRequiresOutcome = false;

  // This property is used to validate / invalidate the Request object. If the object is out-dated, we need to pull the object again
  bool outdated = false;

  @override
  initialize() {
    super.initialize();

    scheduleId = "";
    routeId = "";
    szRecordLocator = "";

    szAssignmentType = "";

    isTbd = false;
    dateTime = null;
    nEstimatedMiles = 0;
    isReturn = false;

    szMessage = "";
    szOutcome = "";

    intDuration = 0;

    enumType = EnumRequestType.transport;
    enumTiming = EnumRequestTiming.arriveBy;
    enumStatus = EnumRequestStatus.requested;
    enumBillingCategory = EnumRequestBillingCategoryType.none;
    refConsumer = ConsumerRefDataModel();
    refUser = UserRefDataModel();
    refOrganization = OrganizationRefDataModel();
    refTransportOrganization = OrganizationRefDataModel();
    refPickup = LocationDataModel();
    refDelivery = LocationDataModel();
    refLocation = LocationDataModel();

    arrayTransfers = [];
    arrayTasks = [];
    arrayForms = [];
    refRoute = RouteRefDataModel();
    szDescription = "";

    isRequiresOutcome = false;

    outdated = false;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "description")) {
      szDescription = UtilsString.parseString(dictionary["description"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "scheduleId")) {
      scheduleId = UtilsString.parseString(dictionary["scheduleId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "routeId")) {
      routeId = UtilsString.parseString(dictionary["routeId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "recordLocator")) {
      szRecordLocator = UtilsString.parseString(dictionary["recordLocator"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "message")) {
      szMessage = UtilsString.parseString(dictionary["message"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "outcome")) {
      szOutcome = UtilsString.parseString(dictionary["outcome"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "assignmentType")) {
      szAssignmentType = UtilsString.parseString(dictionary["assignmentType"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "duration")) {
      intDuration = UtilsString.parseInt(dictionary["duration"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "consumer")) {
      final Map<String, dynamic> consumer = dictionary["consumer"];
      refConsumer.deserialize(consumer);
      refConsumer.organizationId = refOrganization.organizationId;
    }

    if (UtilsBaseFunction.containsKey(dictionary, "user")) {
      final Map<String, dynamic> user = dictionary["user"];
      refUser.deserialize(user);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "time")) {
      dateTime =
          UtilsDate.getDateTimeFromStringWithFormatFromApi(UtilsString.parseString(dictionary["time"]), EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "tbd")) {
      isTbd = UtilsString.parseBool(dictionary["tbd"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "isReturn")) {
      isReturn = UtilsString.parseBool(dictionary["isReturn"], false);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "pickup")) {
      final Map<String, dynamic> pickup = dictionary["pickup"];
      refPickup.deserialize(pickup);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "delivery")) {
      final delivery = dictionary["delivery"];
      refDelivery.deserialize(delivery);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = RequestTypeExtension.fromString(UtilsString.parseString(dictionary["type"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "timing")) {
      enumTiming = RequestTimingExtension.fromString(UtilsString.parseString(dictionary["timing"]));
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = RequestStatusExtension.fromString(UtilsString.parseString(dictionary["status"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "billingCategory")) {
      enumBillingCategory = RequestBillingCategoryTypeExtension.fromString(UtilsString.parseString(dictionary["billingCategory"]));
    }

    if (UtilsBaseFunction.containsKey(dictionary, "organization")) {
      refOrganization.deserialize(dictionary["organization"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "transport")) {
      refTransportOrganization.deserialize(dictionary["transport"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "location")) {
      refLocation.deserialize(dictionary["location"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "transfers")) {
      final List<dynamic> array = dictionary["transfers"];
      for (int i in Iterable.generate(array.length)) {
        final json = array[i];
        final transfer = TransferDataModel();
        transfer.deserialize(json);
        arrayTransfers.add(transfer);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "tasks")) {
      final taskObject = dictionary["tasks"];
      if (taskObject is Map<String, dynamic>) {
        final task = TaskDataModel();
        task.deserialize(taskObject);
        if (task.isValid()) arrayTasks.add(task);
      } else {
        final List<dynamic> array = dictionary["tasks"];
        for (int i in Iterable.generate(array.length)) {
          final json = array[i];
          final task = TaskDataModel();
          task.deserialize(json);
          if (task.isValid()) arrayTasks.add(task);
        }
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "forms")) {
      final List<dynamic> array = dictionary["forms"];
      for (int i in Iterable.generate(array.length)) {
        final json = array[i];
        final form = FormRefDataModel();
        form.deserialize(json);
        arrayForms.add(form);
      }
    }

    if (UtilsBaseFunction.containsKey(dictionary, "route")) {
      refRoute.deserialize(dictionary["route"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "description")) {
      scheduleId = UtilsString.parseString(dictionary["description"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "requiresOutcome")) {
      isRequiresOutcome = UtilsString.parseBool(dictionary["requiresOutcome"], false);
    }
  }

  Map<String, dynamic> serializeForCreateTransport() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["type"] = EnumRequestType.transport.value;
    jsonObject["timing"] = enumTiming.value;
    jsonObject["tbd"] = isTbd;
    jsonObject["time"] = UtilsDate.getStringFromDateTimeWithFormatToApi(dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    jsonObject["pickup"] = refPickup.serialize();
    jsonObject["delivery"] = refDelivery.serialize();

    final List<dynamic> arrayTransferDict = [];
    for (var t in arrayTransfers) {
      arrayTransferDict.add(t.serializeForCreateRequest());
    }
    jsonObject["transfers"] = arrayTransferDict;
    return jsonObject;
  }

  Map<String, dynamic> serializeForCreateService() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["type"] = EnumRequestType.service.value;
    jsonObject["time"] = UtilsDate.getStringFromDateTimeWithFormatToApi(dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    jsonObject["duration"] = intDuration;
    jsonObject["outcome"] = szOutcome;
    jsonObject["location"] = refLocation.serialize();
    jsonObject["consumer"] = refConsumer.serialize();
    jsonObject["user"] = refUser.serialize();

    return jsonObject;
  }

  Map<String, dynamic> serializeForUpdateService() {
    final Map<String, dynamic> jsonObject = {};
    // jsonObject["type"] = EnumRequestType.service.value;
    // jsonObject["time"] = UtilsDate.getStringFromDateTimeWithFormat(
    //     dateTime, EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value, true);
    // jsonObject["duration"] = intDuration;
    // jsonObject["outcome"] = szOutcome;
    // jsonObject["location"] = refLocation.serialize();
    // jsonObject["consumer"] = refConsumer.serialize();
    // jsonObject["user"] = refUser.serialize();

    final List<dynamic> arrayTasksDict = [];
    for (var t in arrayTasks) {
      arrayTasksDict.add(t.serialize());
    }
    jsonObject["tasks"] = arrayTasksDict;
    return jsonObject;
  }

  invalidate() {
    outdated = true;
  }

  @override
  bool isValid() {
    return (id.isNotEmpty && enumStatus != EnumRequestStatus.error && enumStatus != EnumRequestStatus.cancelled && !outdated);
  }

  bool isScheduled() {
    if (!isValid()) return false;

    if (enumStatus == EnumRequestStatus.requested) return false;
    return true;
  }

  String getBeautifiedTransfersText() {
    // This is very similar to RideViewMode.getBeautifiedConsumersText
    if (arrayTransfers.isEmpty) return "N/A";
    var text = arrayTransfers[0].szName;
    if (arrayTransfers.length > 1) {
      text = "$text, ${arrayTransfers.length - 1} more";
    }
    return text;
  }

  bool checkTransferById(String transferId) {
    for (var t in arrayTransfers) {
      if (t.transferId == transferId) return true;
    }
    return false;
  }

  bool isActiveRequest() {
    if (dateTime == null || enumStatus == EnumRequestStatus.completed || enumStatus == EnumRequestStatus.cancelled) {
      return false;
    }

    // if (this.dateTime!!.before(yesterday)) return false
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    //final yesterday = UtilsDate.addDaysToDate(DateTime.now(), -1);
    if (dateTime!.isBefore(yesterday)) return false;

    return true;
  }

  String getBeautifiedDuration() {
    final days = intDuration / 1400;
    final hours = (intDuration % 1400) / 60;
    final mins = intDuration % 60;

    var hourInt = hours.toInt();
    String text = "";

    if (days > 1) {
      text = "$days days";
    } else if (days == 1) {
      text = "$days day";
    }

    if (hourInt > 1) {
      text = "$text$hourInt hours";
    } else if (hourInt == 1) {
      text = "$text$hourInt hour";
    }

    if (mins > 0) {
      if (text.isNotEmpty) {
        text = text + " and ";
      }
      if (mins > 1) {
        text = "$text$mins mins";
      } else {
        text = "$text$mins min";
      }
    }
    return text;
  }

  bool canUpdate() {
    if (enumStatus == EnumRequestStatus.accepted || enumStatus == EnumRequestStatus.requested || enumStatus == EnumRequestStatus.assigned) {
      return true;
    }
    return false;
  }

  bool canCancel() {
    if (enumStatus == EnumRequestStatus.accepted ||
        enumStatus == EnumRequestStatus.requested ||
        enumStatus == EnumRequestStatus.assigned ||
        enumStatus == EnumRequestStatus.scheduled ||
        enumStatus == EnumRequestStatus.submitted) {
      return true;
    }
    return false;
  }

  DateTime? getBestPickupTime() {
    if (refRoute.dateActualPickup != null && enumStatus != EnumRequestStatus.scheduled) {
      return refRoute.dateActualPickup;
    }

    if (refRoute.dateBestPickup != null) {
      return refRoute.dateBestPickup;
    }

    if (enumTiming == EnumRequestTiming.readyBy) {
      return dateTime;
    }
    if (enumTiming == EnumRequestTiming.arriveBy) {
      return dateTime;
    }
    return null;
    /* if (refRoute.dateBestPickup != null) return refRoute.dateBestPickup;
    if (enumTiming == EnumRequestTiming.readyBy) return dateTime;
    return null;*/
  }

  DateTime? getBestDeliveryTime() {
    if (refRoute.dateActualDelivery != null && enumStatus != EnumRequestStatus.scheduled) {
      return refRoute.dateActualDelivery;
    }
    if (refRoute.dateBestDelivery != null) {
      return refRoute.dateBestDelivery;
    }
    if (enumTiming == EnumRequestTiming.arriveBy) return dateTime;

    return null;

    /* if (refRoute.dateBestDelivery != null) return refRoute.dateBestDelivery;
    if (enumTiming == EnumRequestTiming.arriveBy) return dateTime;
    return null;*/
  }

  String getPrimaryConsumerId() {
    if (enumType == EnumRequestType.service) {
      return refConsumer.id;
    }

    for (var transfer in arrayTransfers) {
      if (transfer.enumType == EnumTransferType.consumer) {
        return transfer.transferId;
      }
    }
    return "";
  }
}

enum EnumRequestType {
  transport,
  maintenance,
  outOfOffice,
  service,
  serviceOther,
}

extension RequestTypeExtension on EnumRequestType {
  static EnumRequestType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumRequestType.transport;
    }
    for (var t in EnumRequestType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumRequestType.transport;
  }

  String get value {
    switch (this) {
      case EnumRequestType.transport:
        return "Transport";
      case EnumRequestType.maintenance:
        return "Maintenance";
      case EnumRequestType.outOfOffice:
        return "Out of Office";
      case EnumRequestType.service:
        return "Service";
      case EnumRequestType.serviceOther:
        return "Service-Other";
    }
  }
}

enum EnumRequestStatus { scheduled, assigned, accepted, completed, noShow, requested, enRoute, cancelled, routing, inProgress, error, pending, submitted }

extension RequestStatusExtension on EnumRequestStatus {
  static EnumRequestStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumRequestStatus.requested;
    }
    for (var t in EnumRequestStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumRequestStatus.requested;
  }

  String get value {
    switch (this) {
      case EnumRequestStatus.scheduled:
        return "Scheduled";
      case EnumRequestStatus.assigned:
        return "Assigned";
      case EnumRequestStatus.accepted:
        return "Accepted";
      case EnumRequestStatus.completed:
        return "Completed";
      case EnumRequestStatus.noShow:
        return "No Show";
      case EnumRequestStatus.requested:
        return "Requested";
      case EnumRequestStatus.enRoute:
        return "En Route";
      case EnumRequestStatus.cancelled:
        return "Cancelled";
      case EnumRequestStatus.routing:
        return "Routing";
      case EnumRequestStatus.inProgress:
        return "In Progress";
      case EnumRequestStatus.error:
        return "Error";
      case EnumRequestStatus.pending:
        return "Pending";
      case EnumRequestStatus.submitted:
        return "Submitted";
    }
  }
}

enum EnumRequestBillingCategoryType {
  none,
  work,
  daySupport,
  careerPlanning,
  employmentSupport,
  vocationalHabilitation,
  volunteer,
  education,
  internship,
  other
}

extension RequestBillingCategoryTypeExtension on EnumRequestBillingCategoryType {
  static EnumRequestBillingCategoryType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumRequestBillingCategoryType.none;
    }
    for (var t in EnumRequestBillingCategoryType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumRequestBillingCategoryType.none;
  }

  String get value {
    switch (this) {
      case EnumRequestBillingCategoryType.none:
        return "";
      case EnumRequestBillingCategoryType.work:
        return "Work";
      case EnumRequestBillingCategoryType.daySupport:
        return "Day Support";
      case EnumRequestBillingCategoryType.careerPlanning:
        return "Career Planning";
      case EnumRequestBillingCategoryType.employmentSupport:
        return "Employment Support";
      case EnumRequestBillingCategoryType.vocationalHabilitation:
        return "Vocational Habilitation";
      case EnumRequestBillingCategoryType.volunteer:
        return "Volunteer";
      case EnumRequestBillingCategoryType.education:
        return "Education";
      case EnumRequestBillingCategoryType.internship:
        return "Internship/Practicum";
      case EnumRequestBillingCategoryType.other:
        return "Other";
    }
  }
}

enum EnumRequestTiming { arriveBy, readyBy }

extension RequestTimingExtension on EnumRequestTiming {
  static EnumRequestTiming fromString(String? status) {
    if (status == null || status.isEmpty) return EnumRequestTiming.arriveBy;
    if (status == EnumRequestTiming.arriveBy.value) {
      return EnumRequestTiming.arriveBy;
    }
    if (status == EnumRequestTiming.readyBy.value) {
      return EnumRequestTiming.readyBy;
    }
    return EnumRequestTiming.arriveBy;
  }

  String get value {
    switch (this) {
      case EnumRequestTiming.arriveBy:
        return "Arrive By";
      case EnumRequestTiming.readyBy:
        return "Ready By";
    }
  }
}

enum EnumRequestWayType { oneWay, round }

extension RequestWayTypeExtension on EnumRequestWayType {
  static EnumRequestWayType fromString(String? status) {
    if (status == null || status.isEmpty) return EnumRequestWayType.oneWay;
    if (status == EnumRequestWayType.oneWay.value) {
      return EnumRequestWayType.oneWay;
    }
    if (status == EnumRequestWayType.round.value) {
      return EnumRequestWayType.round;
    }
    return EnumRequestWayType.oneWay;
  }

  String get value {
    switch (this) {
      case EnumRequestWayType.oneWay:
        return "One Way";
      case EnumRequestWayType.round:
        return "Round Trip";
    }
  }
}
