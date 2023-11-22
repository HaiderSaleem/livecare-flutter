import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class AppSettingDataModel {
  EnumSettingMapViewPreference enumMapPreference = EnumSettingMapViewPreference.none;

  initialize() {
    enumMapPreference = EnumSettingMapViewPreference.none;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "map_preference")) {
      enumMapPreference = SettingMapViewPreferenceExtension.fromString(UtilsString.parseString(dictionary["map_preference"]));
    }
  }

  Map<String, dynamic> serialize() {
    return {"map_preference": enumMapPreference.value};
  }
}

enum EnumSettingMapViewPreference { none, waze, googleMaps, appleMaps, hereWeGo }

extension SettingMapViewPreferenceExtension on EnumSettingMapViewPreference {
  static EnumSettingMapViewPreference fromString(String? status) {
    if (status == null || status == "") {
      return EnumSettingMapViewPreference.none;
    }
    for (EnumSettingMapViewPreference t in EnumSettingMapViewPreference.values) {
      if (status.toLowerCase() == t.value.toLowerCase()) return t;
    }
    return EnumSettingMapViewPreference.none;
  }

  String get title {
    switch (this) {
      case EnumSettingMapViewPreference.none:
        return "None";
      case EnumSettingMapViewPreference.waze:
        return "Waze App";
      case EnumSettingMapViewPreference.googleMaps:
        return "Google Maps App";
      case EnumSettingMapViewPreference.appleMaps:
        return "Apple Maps App";
      case EnumSettingMapViewPreference.hereWeGo:
        return "HERE WeGo App";
    }
  }

  String get value {
    switch (this) {
      case EnumSettingMapViewPreference.none:
        return "";
      case EnumSettingMapViewPreference.waze:
        return "Waze";
      case EnumSettingMapViewPreference.googleMaps:
        return "GoogleMaps";
      case EnumSettingMapViewPreference.appleMaps:
        return "AppleMaps";
      case EnumSettingMapViewPreference.hereWeGo:
        return "HERE WeGo";
    }
  }
}
