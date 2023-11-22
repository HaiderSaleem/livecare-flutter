import 'package:livecare/models/request/dataModel/request_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class RequestRefDataModel {
  String requestId = "";
  EnumRequestTiming enumTiming = EnumRequestTiming.arriveBy;
  DateTime? dateTime;

  _initialize() {
    requestId = "";
    enumTiming = EnumRequestTiming.arriveBy;
    dateTime = null;
  }

  deserialize(Map<String, dynamic>? dictionary) {
    _initialize();

    if (dictionary == null) return;

    if (UtilsBaseFunction.containsKey(dictionary, "requestId")) {
      requestId = UtilsString.parseString(dictionary["requestId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "timing")) {
      enumTiming = RequestTimingExtension.fromString(
          UtilsString.parseString(dictionary["timing"]));
    }
    dateTime = null;
  }
}
