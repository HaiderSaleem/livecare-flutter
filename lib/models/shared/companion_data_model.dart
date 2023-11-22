import 'package:livecare/models/shared/special_needs_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class CompanionDataModel {
  String id = "";
  String szName = "";

  SpecialNeedsDataModel modelSpecialNeeds = SpecialNeedsDataModel();

  initialize() {
    id = "";
    szName = "";
    modelSpecialNeeds = SpecialNeedsDataModel();
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "companionId")) {
      id = UtilsString.parseString(dictionary["companionId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }

    if (UtilsBaseFunction.containsKey(dictionary, "specialNeeds")) {
      final Map<String, dynamic> specialNeeds = dictionary["specialNeeds"];
      modelSpecialNeeds.deserialize(specialNeeds);
    }
  }

  Map<String, dynamic> serializeForCreate() {
    return {
      "name": szName,
      "specialNeeds": modelSpecialNeeds.serialize()
    };
  }

  Map<String, dynamic> serializeForUpdate() {
    return {
      "companionId": id,
      "name": szName,
      "specialNeeds": modelSpecialNeeds.serialize()
    };
  }

  bool isValid() => id.isEmpty == false;
}
