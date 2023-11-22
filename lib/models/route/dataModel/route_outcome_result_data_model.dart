import 'package:livecare/models/consumer/dataModel/consumer_ref_data_model.dart';
import 'package:livecare/utils/utils_base_function.dart';
import 'package:livecare/utils/utils_string.dart';

class RouteOutcomeResultDataModel extends ConsumerRefDataModel {
  String requestId = "";
  bool isCompleted = false;
  String szOutcome = "";

  @override
  initialize() {
    super.initialize();
    requestId = "";
    isCompleted = false;
    szOutcome = "";
  }

  @override
  deserialize(Map<String, dynamic>? dictionary) {
    initialize();
    if (dictionary == null) return;
    super.deserialize(dictionary = dictionary);
    if (UtilsBaseFunction.containsKey(dictionary, "requestId")) {
      requestId = UtilsString.parseString(dictionary["requestId"]);
    }
    if (UtilsBaseFunction.containsKey(dictionary, "completed")) {
      isCompleted = UtilsString.parseBool(dictionary["completed"], false);
    }
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> jsonObject = {};
    jsonObject["consumerId"] = super.consumerId;
    jsonObject["requestId"] = requestId;
    jsonObject["outcome"] = szOutcome;
    return jsonObject;
  }
}
