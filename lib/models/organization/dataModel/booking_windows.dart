

import 'package:livecare/models/base/base_data_model.dart';

import '../../../utils/utils_base_function.dart';
import '../../../utils/utils_string.dart';

class BookingWindows extends BaseDataModel{
  bool isActive = false;
  String message = "";


  @override
  initialize() {
    super.initialize();
    isActive = false;
    message = "";

  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();

    if (dictionary == null) return;
    super.deserialize(dictionary);

    if (UtilsBaseFunction.containsKey(dictionary, "active")) {
      isActive = UtilsString.parseBool(dictionary["active"], false);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "message")) {
      message = UtilsString.parseString(dictionary["message"]);
    }

  }



}