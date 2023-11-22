import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class UserRefDataModel {
  String userId = "";
  String szName = "";
  String szUsername = "";
  String szEmail = "";
  String szPhoto = "";

  initialize() {
    userId = "";
    szName = "";
    szUsername = "";
    szEmail = "";
    szPhoto = "";
  }

  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "userId")) {
      userId = UtilsString.parseString(dictionary["userId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "name")) {
      szName = UtilsString.parseString(dictionary["name"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "username")) {
      szUsername = UtilsString.parseString(dictionary["username"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "email")) {
      szEmail = UtilsString.parseString(dictionary["email"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "photo")){
      szPhoto = UtilsString.parseString(dictionary["photo"]);
    }

  }

  /*Map<String, dynamic> serialize() {
    return {"userId": userId, "name": szName, "email": szEmail,"photo":szPhoto};
  }*/
  Map<String, dynamic> serialize() {
    return {"userId": userId};
  }
}
