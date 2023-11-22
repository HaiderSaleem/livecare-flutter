import 'package:livecare/models/shared/geo_point_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class LocationDataModel extends GeoPointDataModel {
  String id = "";
  String locationId = "";
  String organizationId = "";
  String accountId = "";
  String szName = "";
  String szRegion = "";

  @override
  initialize() {
    super.initialize();
    id = "";
    organizationId = "";
    accountId = "";
    szName = "";
    szCounty = "";
    szRegion = "";
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "id")) {
      id = UtilsString.parseString(dictionary["id"]);
      locationId = UtilsString.parseString(dictionary["id"]);
    } else {
      if (UtilsBaseFunction.containsKey(dictionary, "locationId")) {
        id = UtilsString.parseString(dictionary["locationId"]);
        locationId = UtilsString.parseString(dictionary["locationId"]);
      }
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "accountId")) {
      accountId = UtilsString.parseString(dictionary["accountId"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "address")) {
      szAddress = UtilsString.parseString(dictionary["address"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "county")) {
      szCounty = UtilsString.parseString(dictionary["county"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "region")) {
      szRegion = UtilsString.parseString(dictionary["region"]);
    }
  }

  @override
  Map<String, dynamic> serialize() {
    final geometry = super.serialize();
    return {
      "id": id,
      "organizationId": organizationId,
      "accountId": accountId,
      "name": szName,
      "address": szAddress,
      "county": szCounty,
      "region": szName,
      "geometry": geometry
    };
  }

  @override
  bool isValid() {
    if (id.isEmpty) return false;
    return super.isValid();
  }

  bool isValidGeoPoint() {
    if ((fLongitude).abs() < 0.1 && (fLatitude).abs() < 0.1) return false;
    return true;
  }

  bool hasSharedFinancialAccount() {
    return accountId.isNotEmpty;
  }
}
