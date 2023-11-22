import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class SpecialNeedsDataModel {
  bool isWheelchair = false;
  bool isWheelchairLift = false;
  bool isBlind = false;
  bool isDeaf = false;
  bool isWalker = false;
  bool isServiceAnimal = false;
  bool isCarSeat = false;
  bool isLift = false;

  initialize() {
    isWheelchair = false;
    isWheelchairLift = false;
    isBlind = false;
    isDeaf = false;
    isWalker = false;
    isServiceAnimal = false;
    isCarSeat = false;
    isLift = false;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "wheelchair")) {
      isWheelchair = UtilsString.parseBool(dictionary["wheelchair"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "wheelchairLift")) {
      isWheelchairLift =
          UtilsString.parseBool(dictionary["wheelchairLift"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "blind")) {
      isBlind = UtilsString.parseBool(dictionary["blind"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "deaf")) {
      isDeaf = UtilsString.parseBool(dictionary["deaf"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "walker")) {
      isWalker = UtilsString.parseBool(dictionary["walker"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "serviceAnimal")) {
      isServiceAnimal =
          UtilsString.parseBool(dictionary["serviceAnimal"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "carSeat")) {
      isCarSeat = UtilsString.parseBool(dictionary["carSeat"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "lift")) {
      isLift = UtilsString.parseBool(dictionary["lift"], false);
    }
  }

  Map<String, dynamic> serialize() {
    return {
      "wheelchair": isWheelchair,
      "wheelchairLift": isWheelchairLift,
      "blind": isBlind,
      "deaf": isDeaf,
      "walker": isWalker,
      "serviceAnimal": isServiceAnimal,
      "carSeat": isCarSeat,
      "lift": isLift
    };
  }

  bool requiresCare() {
    // any field is true, it requires care-give
    return (isCarSeat ||
        isWheelchair ||
        isLift ||
        isBlind ||
        isDeaf ||
        isWalker ||
        isServiceAnimal);
  }

  List<String> getNeedsArray() {
    List<String> array = [];
    if (isCarSeat) {
      array.add("Car Seat");
    }
    if (isWheelchair) {
      array.add("Wheelchair");
    }
    if (isLift) {
      array.add("Lift");
    }
    if (isBlind) {
      array.add("Blind");
    }
    if (isDeaf) {
      array.add("Deaf");
    }
    if (isWalker) {
      array.add("Walker");
    }
    if (isServiceAnimal) {
      array.add("Service Animal");
    }

    return array;
  }

  clone(SpecialNeedsDataModel needs) {
    isCarSeat = needs.isCarSeat;
    isWheelchair = needs.isWheelchair;
    isLift = needs.isLift;
    isBlind = needs.isBlind;
    isDeaf = needs.isDeaf;
    isWalker = needs.isWalker;
    isServiceAnimal = needs.isServiceAnimal;
  }
}
