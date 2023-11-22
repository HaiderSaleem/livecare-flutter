import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class GeoPointDataModel {
  EnumGeoPointType enumType = EnumGeoPointType.point;
  double fLatitude = 0.0;
  double fLongitude = 0.0;
  String szAddress = "";
  String szCounty = "";
  bool isOffer = false;

  initialize() {
    fLatitude = 0.0;
    fLongitude = 0.0;
    enumType = EnumGeoPointType.point;
    szAddress = "";
    szCounty = "";
    isOffer = false;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "isReturn")) {
      isOffer = UtilsString.parseBool(dictionary["isReturn"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "address")) {
      szAddress = UtilsString.parseString(dictionary["address"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "county")) {
      szCounty = UtilsString.parseString(dictionary["county"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "geometry")) {
      final Map<String, dynamic> location = dictionary["geometry"];
      if (UtilsBaseFunction.containsKey(location, "type")) {
        enumType = GeoPointTypeExtension.fromString(
            (UtilsString.parseString(location["type"])));
      }
      if (UtilsBaseFunction.containsKey(location, "coordinates")) {
        final List<dynamic> coords = location["coordinates"];
        if (coords.length == 2) {
          fLongitude = UtilsString.parseDouble(coords[0], 0.0);
          fLatitude = UtilsString.parseDouble(coords[1], 0.0);
        }
      }
    }
  }

  Map<String, dynamic> serialize() {
    return {
      "type": enumType.value,
      "coordinates": [fLongitude, fLatitude]
    };
  }

  bool isValid() {
    if ((fLongitude.abs()) < 0.1 && (fLatitude.abs()) < 0.1) return false;
    return true;
  }

  bool isSame(GeoPointDataModel otherPoint) {
    if (isValid() == false || otherPoint.isValid() == false) {
      return false;
    }

    if ((fLongitude - otherPoint.fLongitude).abs() > 0.000001) {
      return false;
    }

    if ((fLatitude - otherPoint.fLatitude).abs() > 0.000001) {
      return false;
    }

    return true;
  }

  var coordinates = const LatLng(0.0, 0.0);

  LatLng getCoordinates() {
    coordinates = LatLng(fLatitude.toDouble(), fLongitude.toDouble());
    return coordinates;
  }
}

enum EnumGeoPointType { none, point }

extension GeoPointTypeExtension on EnumGeoPointType {
  static EnumGeoPointType fromString(String? status) {
    if (status == null || status.isEmpty) return EnumGeoPointType.none;
    if (status == EnumGeoPointType.none.value) return EnumGeoPointType.none;
    if (status == EnumGeoPointType.point.value) return EnumGeoPointType.point;
    return EnumGeoPointType.point;
  }

  String get value {
    switch (this) {
      case EnumGeoPointType.none:
        return "";
      case EnumGeoPointType.point:
        return "Point";
    }
  }
}
