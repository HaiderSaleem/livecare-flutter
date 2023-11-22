import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class VehicleRefDataModel {
  String vehicleId = "";
  String szName = "";
  String szPhoto = "";
  int nCapacity = 0;
  int nAmbulatory = 0;
  int nHandicapped = 0;
  String szLicense = "";

  initialize() {
    vehicleId = "";
    szName = "";
    szPhoto = "";
    nCapacity = 0;
    nAmbulatory = 0;
    nHandicapped = 0;
    szLicense = "";
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "vehicleId")) {
      vehicleId = UtilsString.parseString(dictionary["vehicleId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "szLicense")) {
      szLicense = UtilsString.parseString(dictionary["szLicense"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")) {
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "capacity")) {
      nCapacity = UtilsString.parseInt(dictionary["capacity"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "ambulatory")) {
      nAmbulatory = UtilsString.parseInt(dictionary["ambulatory"], 0);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "handicapped")) {
      nHandicapped = UtilsString.parseInt(dictionary["handicapped"], 0);
    }
  }
}
