
import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/organization/dataModel/organization_ref_data_model.dart';
import 'package:livecare/models/request/dataModel/location_data_model.dart';
import 'package:livecare/models/route/dataModel/activity_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class ExperienceDataModel extends BaseDataModel {
  OrganizationRefDataModel refOrganization = OrganizationRefDataModel();

  String szName = "";
  String szDescription = "";

  LocationDataModel? modelLocation;
  LocationDataModel? modelDestination;

  DateTime? dateTime;
  DateTime? dateActual;
  DateTime? dateCompleted;
  DateTime? dateActualReturn;

  EnumExperienceStatus enumStatus = EnumExperienceStatus.none;
  EnumExperienceType enumType = EnumExperienceType.none;

  bool outdated = false;

  //new addded;
  List<ActivityDataModel> arrayActivities = [];

  ExperienceDataModel() {
    initialize();
  }

  @override
  initialize() {
    super.initialize();

    szName = "";
    szDescription = "";
    modelLocation = null;
    modelDestination = null;
    dateTime = null;
    dateActual = null;
    dateCompleted = null;
    dateActualReturn = null;

    enumStatus = EnumExperienceStatus.none;
    enumType = EnumExperienceType.none;

    outdated = false;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    if (dictionary == null) return;

    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "description")) {
      szDescription = UtilsString.parseString(dictionary["description"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "organization")) {
     final Map<String, dynamic> organization = dictionary["organization"];
     refOrganization.deserialize(organization);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "location")) {
     final Map<String, dynamic> location = dictionary["location"];
     modelLocation = LocationDataModel();
     modelLocation?.deserialize(location);
    }
   // Error here parsing(anager Exception--type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>')
    if (UtilsBaseFunction.containsKey(dictionary, "destination")) {
      final List<dynamic> destination = dictionary["destination"];
      modelDestination = LocationDataModel();
      for( int i in Iterable.generate(destination.length)){
        final Map<String, dynamic> dict = destination[i];
        final modelDestination = LocationDataModel();
        modelDestination.deserialize(dict);
      }

    }
    if (UtilsBaseFunction.containsKey(dictionary, "time")) {
      dateTime = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["time"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "actualTime")) {
      dateActual = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualTime"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "completedTime")) {
      dateCompleted = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["completedTime"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "actualReturnTime")) {
      dateActualReturn = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualReturnTime"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "status")) {
      enumStatus = ExperienceStatusExtension.fromString(dictionary["status"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "type")) {
      enumType = ExperienceTypeExtension.fromString(dictionary["type"]);
    }

  }

  @override
  bool isValid() {
    return (id.isNotEmpty &&
        enumStatus != EnumExperienceStatus.none &&
        enumStatus != EnumExperienceStatus.cancelled &&
        !outdated);
  }

  bool isActive() {
    return (isValid() &&
        enumStatus != EnumExperienceStatus.cancelled &&
        enumStatus != EnumExperienceStatus.completed &&
        enumStatus != EnumExperienceStatus.pending);
  }

  DateTime? getBestDate() {
    return dateActual ?? dateTime;
  }

  invalidate() {
    outdated = true;
  }

  ActivityDataModel? getFirstActivity() {
    if (arrayActivities.length < 2) {
      return null;
    }
    return arrayActivities[1];
  }
}

enum EnumExperienceType { none, leisure, group, wellness, community }

extension ExperienceTypeExtension on EnumExperienceType {
  static EnumExperienceType fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumExperienceType.none;
    }
    for (var t in EnumExperienceType.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumExperienceType.none;
  }

  String get value {
    switch (this) {
      case EnumExperienceType.none:
        return "";
      case EnumExperienceType.leisure:
        return "Leisure";
      case EnumExperienceType.group:
        return "Group";
      case EnumExperienceType.wellness:
        return "Wellness";
      case EnumExperienceType.community:
        return "Community";
    }
  }
}

enum EnumExperienceStatus {
  none,
  scheduled,
  pending,
  completed,
  cancelled,
  inProgress
}

extension ExperienceStatusExtension on EnumExperienceStatus {
  static EnumExperienceStatus fromString(String? status) {
    if (status == null || status.isEmpty) {
      return EnumExperienceStatus.none;
    }
    for (var t in EnumExperienceStatus.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumExperienceStatus.none;
  }

  String get value {
    switch (this) {
      case EnumExperienceStatus.none:
        return "";
      case EnumExperienceStatus.scheduled:
        return "Scheduled";
      case EnumExperienceStatus.pending:
        return "Pending";
      case EnumExperienceStatus.completed:
        return "Completed";
      case EnumExperienceStatus.cancelled:
        return "Cancelled";
      case EnumExperienceStatus.inProgress:
        return "In Progress";
    }
  }
}
