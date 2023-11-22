import 'package:livecare/models/base/base_data_model.dart';
import 'package:livecare/models/shared/vehicle_ref_data_model.dart';
import 'package:livecare/models/user/dataModel/user_re_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_date.dart';
import 'package:livecare/utils/utils_string.dart';

class RouteRefDataModel extends BaseDataModel {
  String szName = "";
  VehicleRefDataModel? refVehicle;
  UserRefDataModel? refDriver;
  DateTime? dateEstimatedPickup;
  DateTime? dateEstimatedDelivery;
  DateTime? dateActualPickup;
  DateTime? dateActualDelivery;

  // This property is used to validate / invalidate the Route object. If the object is out-dated, we need to pull the object again
  bool outdated = false;

  // These 2 date fields are used to re-calculate the most correct pickup / delivery times
  DateTime? dateBestPickup;
  DateTime? dateBestDelivery;

  @override
  initialize() {
    super.initialize();

    refVehicle = null;
    refDriver = null;

    dateEstimatedPickup = null;
    dateEstimatedDelivery = null;
    dateActualPickup = null;
    dateActualDelivery = null;
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    super.deserialize(dictionary);
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "estimatedPickup")) {
      dateEstimatedPickup = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["estimatedPickup"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "estimatedDelivery")) {
      dateEstimatedDelivery = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["estimatedDelivery"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "actualPickup")) {
      dateActualPickup = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualPickup"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "actualDelivery")) {
      dateActualDelivery = UtilsDate.getDateTimeFromStringWithFormatFromApi(
          UtilsString.parseString(dictionary["actualDelivery"]),
          EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.value,
          true);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "vehicle")) {
      final Map<String, dynamic> vehicle = dictionary["vehicle"];
      refVehicle = VehicleRefDataModel();
      refVehicle!.deserialize(vehicle);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "driver")) {
      final Map<String, dynamic> driver = dictionary["driver"];
      refDriver = UserRefDataModel();
      refDriver!.deserialize(driver);
    }

    dateBestPickup = dateActualPickup ?? dateEstimatedPickup;
    dateBestDelivery = dateActualDelivery ?? dateEstimatedDelivery;
  }

  invalidate() {
    outdated = true;
  }

  @override
  bool isValid() {
    return id.isNotEmpty;
  }

  String getVehicleName() {
    if (refVehicle == null) {
      return "N/A";
    }
    if (refVehicle!.szName.isNotEmpty) {
      return refVehicle!.szName;
    }
    return "N/A";
  }

  String getDriverName() {
    if (refDriver == null) {
      return "N/A";
    }
    if (refDriver!.szName.isNotEmpty) {
      return refDriver!.szName;
    }
    return "N/A";
  }

  String getVehiclePhoto() {
    if (refVehicle == null) {
      return "";
    }
    if (refVehicle!.szPhoto.isNotEmpty) {
      return refVehicle!.szPhoto;
    }
    return "";
  }

  String getDriverPhoto() {
    if (refDriver == null) {
      return "";
    }
    if (refDriver!.szPhoto.isNotEmpty) {
      return refDriver!.szPhoto;
    }
    return "";
  }

}
