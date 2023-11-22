import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class InstructionDataModel {
  double fDistance = 0.0;
  int intTravelTime = 0;
  double fHeading = 0.0;
  String szStreetName = "";
  String szText = "";
  EnumInstructionSing enumSign = EnumInstructionSing.continueOnStreet;

  initialize() {
    fDistance = 0.0;
    intTravelTime = 0;
    fHeading = 0.0;
    szStreetName = "";
    szText = "";
    enumSign = EnumInstructionSing.continueOnStreet;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "distance")) {
      fDistance = UtilsString.parseDouble(dictionary["distance"], 0.0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "travelTime")) {
      intTravelTime = UtilsString.parseInt(dictionary["travelTime"], 0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "heading")) {
      fHeading = UtilsString.parseDouble(dictionary["heading"], 0.0);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "streetName")) {
      szStreetName = UtilsString.parseString(dictionary["streetName"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "text")) {
      szText = UtilsString.parseString(dictionary["text"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "sign")) {
      enumSign = InstructionSingExtension.fromInt(
          UtilsString.parseInt(dictionary["sign"], 0));
    }
  }
}

enum EnumInstructionSing {
  turnSharpLeft,
  turnLeft,
  turnSlightLeft,
  continueOnStreet,
  turnSlightRight,
  turnRight,
  turnSharpRight,
  finish,
  viaReached,
  useRoundabout,
  keepRight
}

extension InstructionSingExtension on EnumInstructionSing {
  static EnumInstructionSing fromInt(int? status) {
    if (status == null) {
      return EnumInstructionSing.continueOnStreet;
    }
    for (var t in EnumInstructionSing.values) {
      if (status == t.value) return t;
    }
    return EnumInstructionSing.continueOnStreet;
  }

  int get value {
    switch (this) {
      case EnumInstructionSing.turnSharpLeft:
        return -3;
      case EnumInstructionSing.turnLeft:
        return -2;
      case EnumInstructionSing.turnSlightLeft:
        return -1;
      case EnumInstructionSing.continueOnStreet:
        return 0;
      case EnumInstructionSing.turnSlightRight:
        return 1;
      case EnumInstructionSing.turnRight:
        return 2;
      case EnumInstructionSing.turnSharpRight:
        return 3;
      case EnumInstructionSing.finish:
        return 4;
      case EnumInstructionSing.viaReached:
        return 5;
      case EnumInstructionSing.useRoundabout:
        return 6;
      case EnumInstructionSing.keepRight:
        return 7;
    }
  }
}
